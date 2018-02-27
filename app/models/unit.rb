class Unit < ApplicationRecord

	belongs_to :project
	has_one :sale

	def display_name
		unit_no
	end

end
