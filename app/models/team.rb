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
#  current        :boolean          default(TRUE)
#
# Indexes
#
#  index_teams_on_ancestry   (ancestry)
#  index_teams_on_upline_id  (upline_id)
#  index_teams_on_user_id    (user_id)
#

class Team < ApplicationRecord
  belongs_to :user, optional: true
  has_one :previous_team, ->(object) { where("teams.effective_date < ?", object.effective_date).reorder("teams.effective_date DESC") }, through: :user, source: :teams
  has_many :salevalues, dependent: :destroy
  has_many :sales, -> { distinct }, through: :salevalues
  has_many :projects, -> { distinct }, through: :sales
  belongs_to :position, optional: true
  belongs_to :upline, class_name: "Team", optional: true

  has_ancestry orphan_strategy: :adopt

  # validates :parent_id, presence: true, unless: proc { user.admin? }
  validates :user_id, presence: true
  # validate :must_be_less_than_first_sale_date
  validate :check_subtree, unless: proc { new_record? }
  # validates_uniqueness_of :user_id, :scope => [:effective_date]

  scope :visible, -> { where(hidden: false) }
  scope :upline_eq, ->(id) {
          if id.is_a? String
            id = id[/\d+/].to_i
          end
          teams = Team.find_by_sql "SELECT  \"teams\".* FROM \"teams\" WHERE \"teams\".\"user_id\" = #{id}"
          ancestry = ""
          teams.each do |t|
            if t.ancestry.nil?
              ancestry += "teams.ancestry LIKE '#{t.id}/%' OR teams.ancestry = '#{t.id}' OR teams.id = #{t.id}"
            else
              combo = "#{t.ancestry}/#{t.id}"
              ancestry += "teams.ancestry LIKE '#{combo}/%' OR teams.ancestry = '#{combo}' OR teams.id = #{t.id}"
            end
            if t != teams.last
              ancestry += " OR "
            end
          end

          subtree = Team.find_by_sql "SELECT \"teams\".id FROM \"teams\" WHERE (#{ancestry})"
          search(id_in: subtree.map(&:id)).result
        }

  scope :year, ->(year) {
          start_date = "#{year.to_i - 1}-12-16".to_date
          end_date = start_date + 1.year - 1.day
          joins(:sales).where("sales.date >= ?", start_date).where("sales.date <= ?", end_date)
        }
  scope :month, ->(month) {
          joins(:sales).where("extract(month from sales.date) = ?", month.to_date.month)
        }

  scope :at_timepoint, ->(date) {
          where(effective_date: date)
        }

  scope :lteq_timepoint, ->(date) {
          reorder("effective_date DESC").where("effective_date <= ?", date)
        }

  scope :current, -> {
          where(current: true)
        }

  # scope :main, -> {
  # 	team_id = User.pluck(:team_id).uniq.compact
  # 	where(id: team_id)
  # }

  # after_create :create_team_position

  before_save :change_parent_id, unless: proc { skip_callbacks }
  before_save :check_for_existing_record, unless: proc { skip_callbacks || !effective_date_changed? }
  after_rollback :update_existing_record
  after_create :build_ancestry, unless: proc { skip_callbacks || previous_team.nil? }
  before_save :update_children_date, unless: proc { skip_callbacks || new_record? || !effective_date_changed? }
  before_save :set_upline_id, unless: proc { skip_callbacks }
  before_destroy :prevent_destroy
  after_save :reset_sv_team_id, if: proc { effective_date_changed? || !skip_callbacks }
  after_save :update_children_ancestry, if: proc { ancestry_changed? }
  after_save :update_user_upline_id, if: proc { upline_id_changed? }
  before_save :check_current_team

  attr_accessor :skip_callbacks, :call_after_rollback

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

  def other_teams(include_self = true)
    if include_self
      Team.where(user_id: user_id)
    else
      Team.where(user_id: user_id).where.not(id: id)
    end
  end

  def team_at_timepoint(date, include_self = true)
    if include_self
      Team.where(user_id: user_id).find_by(effective_date: date)
    else
      Team.where(user_id: user_id).where.not(id: id).find_by(effective_date: date)
    end
  end

  def parent_lteq_timepoint(effective_date)
    Team.where(user_id: parent&.user_id)&.lteq_timepoint(effective_date)&.first
  end

  def other_teams_lteq_timepoint(effective_date, include_self = true)
    other_teams(include_self)&.lteq_timepoint(effective_date)&.first
  end

  def check_current_team
    c_team = user.current_team
    other_teams(true).each do |t|
      if t == c_team
        t.update_column(:current, true)
      else
        t.update_column(:current, false)
      end
    end
  end

  protected

  def must_be_less_than_first_sale_date
    first_sale_date = user.sales&.first&.date
    first_effective_date = other_teams.order(:effective_date).first.effective_date
    unless first_sale_date.nil? || (first_sale_date.present? && first_effective_date <= first_sale_date)
      errors.add(:effective_date, "must be earlier than first sale date (#{first_sale_date})")
    end
  end

  def check_subtree
    if subtree&.pluck(:id)&.include?(upline_id)
      errors.add(:upline_id, "must not be yourself or downline at the same time")
    end
  end

  def change_parent_id
    if upline_id_changed?
      self.parent_id = upline_id
    end
    new_parent_id = self.parent_lteq_timepoint(effective_date)&.id
    if parent_id != new_parent_id
      self.parent_id = new_parent_id
    end
  end

  def check_for_existing_record
    team = team_at_timepoint(effective_date, false)
    # if present -> update_existing_team
    # if not present -> build_ancestry (new record)
    if team.present?
      if new_record?
        throw :abort
      else
        update_existing_record
        previous = other_teams_lteq_timepoint(effective_date_was, false)
        if previous
          # adapt previous time point settings unless previous time point is the new team
          unless effective_date < effective_date_was && previous == team
            self.parent_id = previous.parent_lteq_timepoint(effective_date)&.id
            self.attributes = previous.attributes.except("id", "effective_date", "ancestry", "hidden", "created_at", "updated_at")
          end
        end
        self.hidden = true
        self.effective_date = effective_date_was
      end
    end
  end

  def update_existing_record
    team = team_at_timepoint(effective_date, false)
    if team.present?
      team.hidden = false
      team.attributes = self.attributes.except("id", "effective_date", "ancestry", "hidden", "created_at", "updated_at")
      team.save
    end
  end

  def build_ancestry
    previous_team&.children&.each do |t|
      team = t.dup
      team.effective_date = effective_date
      team.upline_id = id
      team.parent_id = id
      team.save
    end
  end

  def update_children_date
    self.children.find_each do |t|
      t.skip_callbacks = true
      t.effective_date = effective_date if t.hidden
    end
  end

  # def create_new_timepoint
  # 	unless new_record?
  # 		previous = other_teams.where('teams.effective_date < ?', effective_date_was).reorder('teams.effective_date DESC').first
  # 		if saved_change_to_effective_date? && previous.present?
  # 			new_team = self.dup
  # 			self.effective_date = effective_date_was
  # 			self.hidden = true
  # 			# adapt previous time point settings unless previous time point is the new team
  # 			unless new_team.effective_date < effective_date_was && previous.effective_date < new_team.effective_date
  # 				self.parent_id = previous.parent&.team_at_timepoint(effective_date_was)&.id
  # 				self.attributes = previous.attributes.except('id', 'effective_date', 'ancestry', 'hidden', 'created_at', 'updated_at')
  # 			end
  # 			self.save
  # 			new_team.save
  # 		end
  # 	end
  # end

  def prevent_destroy
    if previous_team
      self.parent_id = previous_team.parent_lteq_timepoint(effective_date)&.id
      self.attributes = previous_team.attributes.except("id", "effective_date", "ancestry", "hidden", "created_at", "updated_at")
    end
    self.hidden = true
    save
    throw :abort
  end

  def set_upline_id
    if ancestry_changed?
      self.upline_id = parent_id
    end
  end

  def update_children_ancestry
    children.each do |t|
      ancestry ||= ""
      t.update(ancestry: ancestry + "/#{id}", skip_callbacks: true)
    end
  end

  def update_user_upline_id
    user.update_column(:upline_id, upline_id)
  end

  def reset_sv_team_id
    user.salevalues.find_each do |sv|
      sv.adjust_team_id
      sv.save
    end
  end
end
