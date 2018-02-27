class Sale < ApplicationRecord

	has_many :salevalues, dependent: :destroy
	has_many :other_salevalues, -> {other_team}, class_name: 'Salevalue', dependent: :destroy
	has_many :users, -> {distinct}, through: :salevalues
	has_many :teams, -> {distinct}, through: :salevalues
	belongs_to :project
	has_one :unit
	belongs_to :commission, optional: true

	accepts_nested_attributes_for :salevalues
	accepts_nested_attributes_for :other_salevalues

	validates :date, presence: true
	validates :unit_no, presence: true
	validates :spa_value, presence: true
	validates :nett_value, presence: true
	validates :buyer, presence: true

	enum status: ["Booked","Done","Cancelled"]

	scope :by_upline, ->(id) { where(id: User.find(id[/\d+/].to_i).pseudo_team_sales.pluck(:id)) }
	scope :not_cancelled, ->{search(status_not_eq: 2).result}

	def display_name
		"Sale \##{id}"
	end

	def self.ransackable_scopes(_auth_object = nil)
	  [:by_upline]
	end

end
