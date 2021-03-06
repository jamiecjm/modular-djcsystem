# == Schema Information
#
# Table name: positions
#
#  id         :bigint(8)        not null, primary key
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

	has_many :teams, dependent: :destroy
	has_many :positions_commissions, dependent: :destroy
	has_many :commissions, -> {distinct}, through: :positions_commissions

	accepts_nested_attributes_for :teams

	def display_name
		title
	end

	def self.default
		Position.find_by(default: true)
	end

end
