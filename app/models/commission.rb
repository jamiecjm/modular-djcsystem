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
#  position_id    :integer
#
# Indexes
#
#  index_commissions_on_id_and_project_id  (id,project_id)
#  index_commissions_on_position_id        (position_id)
#

class Commission < ApplicationRecord

	belongs_to :project, optional: true
	belongs_to :position
	has_many :sales, autosave: true

	after_save :recalculate_sv
	after_destroy :recalculate_sv

	def display_name
		percentage
	end

	def recalculate_sv
		project.sales.each do |s|
			s.set_comm
			s.save
		end
	end

end
