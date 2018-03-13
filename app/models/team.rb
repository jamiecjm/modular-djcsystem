# == Schema Information
#
# Table name: teams
#
#  id             :integer          not null, primary key
#  name           :string
#  user_id        :integer
#  ancestry       :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  effective_date :date
#
# Indexes
#
#  index_teams_on_ancestry  (ancestry)
#  index_teams_on_user_id   (user_id)
#

class Team < ApplicationRecord

	belongs_to :user, optional: true
	has_many :salevalues
	has_many :sales, -> {distinct}, through: :salevalues
	has_many :projects, ->{distinct}, through: :sales
	has_many :teams_positions, ->{order(:effective_date)}, dependent: :destroy
	has_one :current_teams_position, ->{order('teams_positions.effective_date DESC')}, class_name: 'TeamsPosition'
	has_many :positions, through: :teams_positions
	has_one :current_position, through: :current_teams_position, source: :position

	has_ancestry orphan_strategy: :adopt

	validates :parent_id, presence: true, unless: proc { root? }
	validates :user_id, presence: true

	scope :upline_eq, ->(id) {
		if id.is_a? String
			id = id[/\d+/].to_i
		end
		team = Team.find_by_sql "SELECT  \"teams\".* FROM \"teams\" WHERE \"teams\".\"user_id\" = #{id}"
		team = team.first
		if team.ancestry.nil?
			ancestry = "#{team.id}"
		else
			ancestry = "#{team.ancestry}/#{team.id}"
		end
		subtree = Team.find_by_sql "SELECT \"teams\".id FROM \"teams\" WHERE ((\"teams\".\"ancestry\" LIKE '#{ancestry}/%' OR \"teams\".\"ancestry\" = '#{ancestry}') OR \"teams\".\"id\" = #{team.id})"
		search(id_in: subtree.map(&:id)).result
	}

	scope :year, ->(year) {
		start_date = "#{year.to_i-1}-12-16".to_date
		end_date = start_date + 1.year - 1.day
		joins(:sales).where('sales.date >= ?', start_date).where('sales.date <= ?', end_date)
	}
	scope :month, ->(month) {
		joins(:sales).where('extract(month from sales.date) = ?', month.to_date.month)
	}

	# scope :main, -> {
	# 	team_id = User.pluck(:team_id).uniq.compact
	# 	where(id: team_id)
	# }

	after_create :create_team_position

	def members
		subtree
	end

	def team_sales
		Sale.search(teams_id_in: subtree.ids).result
	end

	def display_name
		name ||= user&.prefered_name
	end

	def self.ransackable_scopes(_auth_object = nil)
	  [:upline_eq, :year, :month]
	end

	def create_team_position
		TeamsPosition.create(team_id: id, position_id: 2, effective_date: Date.today)
	end

end
