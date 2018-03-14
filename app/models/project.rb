# == Schema Information
#
# Table name: projects
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Project < ApplicationRecord

	# has_many :units, dependent: :destroy
	has_many :commissions, -> {order(:effective_date)}, dependent: :destroy
	has_many :positions_commissions, through: :commissions
	has_many :sales, dependent: :destroy, autosave: true

	accepts_nested_attributes_for :commissions

	validates :name, presence: true
	validates :name, uniqueness: true
	validates :commissions, presence: true

	# after_initialize :initialize_comm

	def titleize_name
		self.name = name.upcase_first_word
	end

	def initialize_comm
		commissions.build(project_id: id) if name.nil? && commissions.blank?
	end
end
