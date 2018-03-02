class Project < ApplicationRecord

	has_many :units, dependent: :destroy
	has_many :commissions, dependent: :destroy
	has_many :sales, dependent: :destroy

	accepts_nested_attributes_for :commissions

	validates :name, presence: true
	validates :commissions, presence: true

	def titleize_name
		self.name = name.upcase_first_word
	end
end
