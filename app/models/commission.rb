class Commission < ApplicationRecord

	belongs_to :project
	has_many :sales

	def display_name
		percentage
	end

end
