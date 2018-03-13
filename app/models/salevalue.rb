# == Schema Information
#
# Table name: salevalues
#
#  id         :integer          not null, primary key
#  percentage :float
#  nett_value :float
#  spa        :float
#  comm       :float
#  user_id    :integer
#  sale_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  order      :integer
#  other_user :string
#  team_id    :integer
#
# Indexes
#
#  index_salevalues_on_sale_id  (sale_id)
#  index_salevalues_on_user_id  (user_id)
#

class Salevalue < ApplicationRecord

	belongs_to :team, optional: true
	has_one :user, through: :team
	has_many :positions, through: :team
	has_one :current_position, through: :team
	belongs_to :sale, optional: true
	has_one :project, through: :sale
	# has_one :unit, through: :sale
	has_one :commission, through: :sale
	has_many :position_commissions, through: :commission
	has_one :default_commission, -> {where(position_id: Position.default.id)}, through: :commission, source: :position_commissions
	has_one :current_commission, -> (object){where(position_id: object.current_position.id)}, through: :commission, source: :position_commissions

	validates :percentage, presence: true
	validates :team_id, presence: true, if: proc { other_user.blank? }
	validates :other_user, presence: true, if: proc { team_id.blank? }

	scope :other_team, -> {where.not(other_user: nil)}
	scope :not_cancelled, -> { search(sale_status_not_eq: 'Cancelled').result }
	scope :cancelled, -> { search(sale_status_eq: 'Cancelled').result }
	scope :year, -> (year) {
		start_date = "#{year.to_i-1}-12-16".to_date
		end_date = start_date + 1.year - 1.day
		joins(:sale).where('sales.date >= ?', start_date).where('sales.date <= ?', end_date)
	}
	scope :month, -> (month) {
		joins(:sale).where('extract(month from sales.date) = ?', month.to_date.month)
	}

	before_save :calc_comm

	def self.ransackable_scopes(_auth_object = nil)
	  [:year, :month]
	end

	def calc_comm
		comm = position_commissions.find_by(position_id: Position.default.id)
		self.spa = sale.spa_value * percentage/100
		self.nett_value = sale.nett_value * percentage/100
		self.comm = nett_value * comm.percentage/100
		calc_override(comm.percentage)
	end

	def calc_override(base_comm)
		teams = team.ancestors
		teams.each do |t|
			position = t.current_position
			comm = position_commissions.find_by(position_id: position.id)
			o = OverridingCommission.find_or_initialize_by(team_id: t.id, salevalue_id: id)
			if comm && comm.percentage > base_comm
				override = nett_value * (comm.percentage-base_comm)/100
				o.override = override
				o.save
			else
				o.destroy
			end
		end
	end

end
