class Commission < ApplicationRecord

	belongs_to :project, optional: true
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
