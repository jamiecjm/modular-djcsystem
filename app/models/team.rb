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
#  position_id    :integer
#  effective_date :date
#  upline_id      :integer
#
# Indexes
#
#  index_teams_on_ancestry   (ancestry)
#  index_teams_on_upline_id  (upline_id)
#  index_teams_on_user_id    (user_id)
#

class Team < ApplicationRecord

	belongs_to :user, optional: true
	has_many :salevalues, dependent: :destroy
	has_many :sales, -> {distinct}, through: :salevalues
	has_many :projects, ->{distinct}, through: :sales
	belongs_to :position
	belongs_to :upline, class_name: 'Team', optional: true

	has_ancestry orphan_strategy: :adopt

	validates :parent_id, presence: true, unless: proc { root? }
	validates :user_id, presence: true

	scope :upline_eq, ->(id) {
		if id.is_a? String
			id = id[/\d+/].to_i
		end
		teams = Team.find_by_sql "SELECT  \"teams\".* FROM \"teams\" WHERE \"teams\".\"user_id\" = #{id}"
		ancestry = ''
		teams.each do |t|
			if t.ancestry.nil?
				ancestry += "teams.ancestry LIKE '#{t.id}/%' OR teams.ancestry = '#{t.id}' OR teams.id = #{t.id}" 
			else
				combo = "#{team.ancestry}/#{team.id}"
				ancestry += "teams.ancestry LIKE '#{combo}/%' OR teams.ancestry = '#{combo}' OR teams.id = #{t.id}" 
			end		
			if t != teams.last
				ancestry += ' OR '
			end	
		end

		subtree = Team.find_by_sql "SELECT \"teams\".id FROM \"teams\" WHERE (#{ancestry})"
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
	before_save :set_upline_id

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

	def set_upline_id
		self.upline_id = ancestry&.split('/')&.last if ancestry_changed?
	end

end
