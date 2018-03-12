class Team < ApplicationRecord

	has_many :users
	belongs_to :leader, class_name: 'User', optional: true
	has_one :main_team, class_name: 'Team', through: :leader, source: :team
	has_many :salevalues, -> {distinct}, through: :leader
	has_many :sales, -> {distinct}, through: :salevalues
	has_many :projects, ->{distinct}, through: :sales
	has_many :teams_positions
	has_many :positions, through: :teams_positions

	has_ancestry orphan_strategy: :adopt

	validates :parent_id, presence: true, unless: proc { root? }
	validates :leader_id, presence: true

	scope :upline_eq, ->(id) {
		if id.is_a? String
			id = id[/\d+/].to_i
		end
		user = User.find(id)
		team = Team.find_by_sql "SELECT  \"teams\".* FROM \"teams\" WHERE \"teams\".\"leader_id\" = #{user.id}"
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

	scope :current_position, -> {positions.last}

	scope :main, -> {
		team_id = User.pluck(:team_id).uniq.compact
		where(id: team_id)
	}

	after_create :create_team_position

	def members
		# including subtree
		user_ids = subtree.pluck(:leader_id)
		User.where(id: user_ids)
	end

	def display_name
		name ||= leader&.prefered_name
	end

	def self.ransackable_scopes(_auth_object = nil)
	  [:upline_eq, :year, :month]
	end

	def create_team_position
		TeamsPosition.create(team_id: id, position_id: 2, effective_date: Date.today)
	end

end
