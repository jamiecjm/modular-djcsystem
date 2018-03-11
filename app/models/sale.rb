class Sale < ApplicationRecord

	extend Enumerize

	has_many :salevalues, dependent: :destroy
	has_many :main_salevalues, -> {where(other_user: nil).order(:order)}, class_name: 'Salevalue', dependent: :destroy
	has_many :other_salevalues, -> {other_team.order(:order)}, class_name: 'Salevalue', dependent: :destroy
	has_many :users, -> {distinct}, through: :salevalues
	has_many :teams, -> {distinct}, through: :salevalues
	belongs_to :project, optional: true
	has_one :unit
	belongs_to :commission, optional: true

	accepts_nested_attributes_for :main_salevalues
	accepts_nested_attributes_for :other_salevalues

	validates :date, presence: true
	validates :unit_no, presence: true
	validates :spa_value, presence: true
	validates :nett_value, presence: true
	validates :buyer, presence: true
	validates :main_salevalues, :presence => true

	enumerize :status, in: ["Booked","Done","Cancelled"]

	scope :upline_eq, ->(id) { 
		if id.is_a? String
			id = id[/\d+/].to_i
		end
		where(id: User.find(id).pseudo_team_sales.pluck(:id)) 
	}
	scope :not_cancelled, ->{search(status_not_eq: "Cancelled").result}
	scope :year, ->(year) {}
	scope :month, ->(month) {}

	before_save :set_comm

	def display_name
		"Sale \##{id}"
	end

	def self.ransackable_scopes(_auth_object = nil)
	  [:upline_eq, :year, :month]
	end

	def set_comm
		comm = project.commissions.where('effective_date <= ?', date).last
		self.commission_id = comm.id
		salevalues.each do |sv|
			sv.calc_comm
			sv.save
		end
	end

	def titleize_buyer
		self.buyer = buyer.upcase_first_word
	end

	def upcase_unit_no
		self.unit_no = unit_no.upcase
	end

end
