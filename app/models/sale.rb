# == Schema Information
#
# Table name: sales
#
#  id            :integer          not null, primary key
#  date          :date
#  buyer         :string
#  project_id    :integer
#  package       :string
#  remark        :string
#  spa_sign_date :date
#  la_date       :date
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  commission_id :integer
#  unit_no       :string
#  unit_size     :integer
#  spa_value     :float
#  nett_value    :float
#  status        :string           default("Booked")
#  booking_form  :string
#
# Indexes
#
#  index_sales_on_commission_id  (commission_id)
#  index_sales_on_date           (date)
#  index_sales_on_project_id     (project_id)
#

class Sale < ApplicationRecord

	extend Enumerize

	has_many :salevalues, dependent: :destroy
	has_many :main_salevalues, -> {where(other_user: nil).order(:order)}, class_name: 'Salevalue', dependent: :destroy
	has_many :other_salevalues, -> {other_team.order(:order)}, class_name: 'Salevalue', dependent: :destroy
	has_many :teams, through: :main_salevalues
	has_many :users, through: :teams
	belongs_to :project, optional: true
	# has_many :commissions, through: :project
	belongs_to :commission, optional: true
	has_many :positions_commissions, through: :commission
	has_one :default_positions_commission, through: :commission

	mount_uploader :booking_form, AttachmentUploader

	accepts_nested_attributes_for :main_salevalues, allow_destroy: true
	accepts_nested_attributes_for :other_salevalues, allow_destroy: true

	validates :date, presence: true
	validates :status, presence: true
	validates :unit_no, presence: true
	validates :spa_value, presence: true
	validates :nett_value, presence: true
	validates :project_id, presence: true
	validates :buyer, presence: true
	validates :main_salevalues, :presence => true

	enumerize :status, in: ["Booked","Done","Cancelled"]

	scope :upline_eq, ->(id) {
		if id.is_a? String
			id = id[/\d+/].to_i
		end
		where(id: User.find(id).all_team_sales.pluck(:id))
	}
	scope :not_cancelled, ->{search(status_not_eq: "Cancelled").result}
	scope :year, ->(year) {
		start_date = "#{year.to_i-1}-12-16".to_date
		end_date = start_date + 1.year - 1.day
		where('date >= ?', start_date).where('date <= ?', end_date)
	}
	scope :month, ->(month) {
		where('extract(month from date) = ?', month.to_date.month)
	}

	before_save :set_comm
	after_save :recalculate_sv, unless: proc {id_changed?}
	# after_initialize :initialize_sv

	def display_name
		"Sale \##{id}"
	end

	def self.ransackable_scopes(_auth_object = nil)
	  [:upline_eq, :year, :month]
	end

	def set_comm
		self.commission_id = project.commissions.where('commissions.effective_date <= ?', date).reorder('commissions.effective_date').last.id
	end

	def recalculate_sv
		salevalues.each do |s|
			s.calc_spa if spa_value_changed?
			s.calc_nett_value if nett_value_changed?
			s.recalc_comm if commission_id_changed?
			s.save
		end
	end

	def titleize_buyer
		self.buyer = buyer.upcase_first_word
	end

	def upcase_unit_no
		self.unit_no = unit_no.upcase
	end

	def initialize_sv
		main_salevalues.build
	end

end
