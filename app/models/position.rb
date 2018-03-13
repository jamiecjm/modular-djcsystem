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

	has_many :teams_positions, dependent: :destroy
	has_many :teams, -> {distinct}, through: :teams_positions
	has_many :position_commissions, dependent: :destroy
	has_many :commissions, -> {distinct}, through: :position_commissions

	accepts_nested_attributes_for :teams

	def display_name
		title
	end

	def self.default
		Position.find_by(default: true)
	end

end
