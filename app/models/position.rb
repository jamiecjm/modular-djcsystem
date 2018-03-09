class Position < ApplicationRecord

	has_ancestry

	has_many :teams_positions
	has_many :teams, -> {distinct}, through: :teams_positions

	def display_name
		title
	end

end
