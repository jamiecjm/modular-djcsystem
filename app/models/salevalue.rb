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
#
# Indexes
#
#  index_salevalues_on_sale_id  (sale_id)
#  index_salevalues_on_user_id  (user_id)
#

class Salevalue < ApplicationRecord

	belongs_to :user, optional: true
	has_one :team, through: :user
	belongs_to :sale, optional: true
	has_one :project, through: :sale
	has_one :unit, through: :sale
	has_one :commission, through: :sale

	validates :percentage, presence: true
	validates :user_id, presence: true, if: proc { other_user.blank? }
	validates :other_user, presence: true, if: proc { user_id.blank? }

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
		position = user.positions.where('effective_date <= ?', sale.date).last
		comm = project.commissions.where('effective_date <= ?', sale.date).where(position_id: position.id).last
		self.spa = sale.spa_value * percentage/100
		self.nett_value = sale.nett_value * percentage/100
		self.comm = nett_value * comm.percentage/100
		calc_override(comm.percentage)
	end

	def calc_override(base_comm)
		teams = user.pseudo_team.ancestors
		teams.each do |t|
			position = t.positions.where('effective_date <= ?', sale.date).last
			comm = project.commissions.where('effective_date <= ?', sale.date).where(position_id: position.id).last	
			o = Overriding.find_or_initialize_by(team_id: t.id, salevalue_id: id)
			if !comm.blank?	
				override = nett_value * (comm.percentage-base_comm)/100
				o.override = override
				o.save
			else
				o.destroy
			end
		end
	end

end
