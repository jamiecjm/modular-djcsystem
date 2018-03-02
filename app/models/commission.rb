class Commission < ApplicationRecord

	belongs_to :project
	has_many :sales

	before_save :recalculate_sv

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
