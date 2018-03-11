class Unit < ApplicationRecord

	belongs_to :project, optional: true
	has_one :sale

	def display_name
		unit_no
	end

end
