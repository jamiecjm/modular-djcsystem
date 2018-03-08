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
	scope :not_cancelled, -> { search(sale_status_not_eq: 2).result }
	scope :cancelled, -> { search(sale_status_eq: 2).result }
	scope :year, -> (year) {}
	scope :month, -> (year) {}

	before_save :calc_comm

	def self.ransackable_scopes(_auth_object = nil)
	  [:year, :month]
	end

	def calc_comm
		self.spa = sale.spa_value * percentage/100
		self.nett_value = sale.nett_value * percentage/100
		self.comm = nett_value * commission.percentage/100
	end

end
