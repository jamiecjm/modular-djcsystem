class Position < ApplicationRecord

	has_ancestry orphan_strategy: :adopt

	has_many :teams_positions
	has_many :teams, -> {distinct}, through: :teams_positions

	accepts_nested_attributes_for :teams

	def display_name
		title
	end

end
