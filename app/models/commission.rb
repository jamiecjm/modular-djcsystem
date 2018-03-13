# == Schema Information
#
# Table name: commissions
#
#  id             :integer          not null, primary key
#  project_id     :integer
#  percentage     :float
#  effective_date :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_commissions_on_id_and_project_id  (id,project_id)
#

class Commission < ApplicationRecord

	belongs_to :project, optional: true
	has_many :position_commissions
	has_many :positions, -> {distinct.ordered_by_ancestry.reverse}, through: :position_commissions
	has_many :sales, autosave: true

	after_save :recalculate_sv
	after_destroy :recalculate_sv
	after_initialize :initialize_position_commission

	validates :effective_date, presence: true

	accepts_nested_attributes_for :position_commissions

	scope :by_date, ->(date){ where('effective_date <= ?', date) }

	def display_name
		percentage
	end

	def recalculate_sv
		project.sales.each do |s|
			s.set_comm
			s.save
		end
	end

	def initialize_position_commission
		if new_record?
			Position.all.ordered_by_ancestry.reverse.each do |p| 
				position_commissions.build(position_id: p.id)
			end
		end
	end

end
