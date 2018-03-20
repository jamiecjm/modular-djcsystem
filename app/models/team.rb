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
#  position_id    :integer
#  upline_id      :integer
#  hidden         :boolean          default(FALSE)
#
# Indexes
#
#  index_teams_on_ancestry   (ancestry)
#  index_teams_on_upline_id  (upline_id)
#  index_teams_on_user_id    (user_id)
#

class Team < ApplicationRecord

	belongs_to :user, optional: true
	has_one :previous_team, ->(object){where('teams.effective_date < ?', object.effective_date).reorder('teams.effective_date DESC')}, through: :user, source: :teams
	has_many :salevalues, dependent: :destroy
	has_many :sales, -> {distinct}, through: :salevalues
	has_many :projects, ->{distinct}, through: :sales
	belongs_to :position, optional: true
	belongs_to :upline, class_name: 'Team', optional: true

	has_ancestry orphan_strategy: :adopt

	# validates :parent_id, presence: true, unless: proc { user.admin? }
	validates :user_id, presence: true
	# validates_uniqueness_of :user_id, :scope => [:effective_date]

	scope :visible, ->{where(hidden: false)}
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
				combo = "#{t.ancestry}/#{t.id}"
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

	# after_create :create_team_position
	before_save :set_upline_id
	before_save :create_new_timepoint, unless: proc { skip_create_new_timepoint }
	after_create :build_root, unless: proc { skip_build_root || previous_team.nil? }
	# after_save :reset_attr_accessor
	before_destroy :prevent_destroy

	attr_accessor :skip_build_root, :skip_create_new_timepoint

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

	def other_teams
		Team.where(user_id: user_id)
	end

	def team_at_timepoint(date)
		Team.where(user_id: user_id).find_by(effective_date: date)
	end

	protected

	def set_upline_id
		self.upline_id = ancestry&.split('/')&.last
	end

	def build_root
		# assume ancestry is not nil
		if previous_team.root?
			build_ancestry
		else
			team = previous_team.root.dup
			team.effective_date = effective_date
			team.skip_build_root = true
			team.save
			team.build_ancestry			
		end
	end

	def build_ancestry
		previous_team&.children.each do |t|
			team = t.team_at_timepoint(effective_date)
			if !team
				if t.effective_date != effective_date
					team = t.dup
					team.effective_date = effective_date
				else
					team = t
				end
				if team.parent_id
					team.parent_id = id
				end
				team.skip_create_new_timepoint = true
				team.skip_build_root = true
				team.save
			end
			team.build_ancestry
		end
	end

	def create_new_timepoint
		unless new_record?
			if effective_date_changed? && previous_team
				new_team = self.dup
				self.effective_date = effective_date_was
				self.hidden = true
				if new_team.effective_date < effective_date_was
					previous = user.teams.where('teams.effective_date < ?', effective_date).reorder('teams.effective_date DESC').first
				else
					previous = previous_team
				end
				# adapt previous time point settings unless previous time point is the new team
				unless new_team.effective_date < effective_date_was && previous.effective_date < new_team.effective_date
					self.parent_id = previous.parent.user.teams.find_by(effective_date: effective_date_was).id
					self.attributes = previous.attributes.except('id', 'effective_date', 'ancestry', 'hidden', 'created_at', 'updated_at')
				end
				self.save
				# find record at the specific time point
				team = team_at_timepoint(new_team.effective_date)
				if team
					parent = new_team.parent&.team_at_timepoint(new_team.effective_date)
					team.hidden = false
					team.parent_id = parent&.id
					team.attributes = new_team.attributes.except('id', 'effective_date', 'ancestry', 'hidden', 'created_at', 'updated_at')
					team.save
				else
					new_team.save
				end
			end
		end
	end

	def prevent_destroy
		self.hidden = true
		if previous_team
			self.parent_id = previous_team.parent.user.teams.find_by(effective_date: effective_date).id
			self.attributes = previous_team.attributes.except('id', 'effective_date', 'ancestry', 'created_at', 'updated_at')
			save
		end
		throw :abort
	end

	def reset_attr_accessor
		skip_build_root = nil
		skip_create_new_timepoint = nil
	end

end
