class Project < ApplicationRecord

	has_many :units, dependent: :destroy
	has_many :commissions, -> {order(:effective_date)}, dependent: :destroy
	has_many :sales, dependent: :destroy, autosave: true

	accepts_nested_attributes_for :commissions

	validates :name, presence: true
	validates :commissions, presence: true

	def titleize_name
		self.name = name.upcase_first_word
	end
end
