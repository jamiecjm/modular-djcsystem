# == Schema Information
#
# Table name: positions
#
#  id         :integer          not null, primary key
#  title      :string
#  overriding :boolean          default(FALSE)
#  ancestry   :string
#  default    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_positions_on_ancestry  (ancestry)
#

class Position < ApplicationRecord

	has_ancestry orphan_strategy: :adopt

	has_many :teams_positions
	has_many :teams, -> {distinct}, through: :teams_positions

	accepts_nested_attributes_for :teams

	def display_name
		title
	end

end
