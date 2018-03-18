# == Schema Information
#
# Table name: commissions
#
#  id             :integer          not null, primary key
#  project_id     :integer
#  percentage     :float
#  effective_date :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_commissions_on_id_and_project_id  (id,project_id)
#

class Commission < ApplicationRecord

	belongs_to :project, optional: true
	has_many :positions_commissions, dependent: :destroy
	has_one :default_positions_commission, -> {where(position_id: Position.default.id)}, class_name: 'PositionsCommission'
	has_many :positions, -> {distinct.ordered_by_ancestry.reverse}, through: :positions_commissions
	has_many :sales, through: :project
	has_many :salevalues, through: :sales, autosave: true

	after_save :recalculate_sv
	after_destroy :recalculate_sv
	after_initialize :initialize_position_commission

	validates :effective_date, presence: true

	accepts_nested_attributes_for :positions_commissions

	scope :by_date, ->(date){ where('commissions.effective_date <= ?', date) }

	def display_name
		percentage
	end

	def recalculate_sv
		salevalues.each do |s|
			s.calc_comm
			s.save
		end
	end

	def initialize_position_commission
		if new_record? && positions_commissions.blank?
			positions_commissions.build(position_id: Position.default.id)
		
			# Position.all.ordered_by_ancestry.reverse.each do |p| 
			# 	positions_commissions.build(position_id: p.id)
			# end		
		end
	end

end
