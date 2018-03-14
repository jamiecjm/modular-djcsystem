# == Schema Information
#
# Table name: positions_commissions
#
#  id            :integer          not null, primary key
#  position_id   :integer
#  percentage    :float
#  commission_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_positions_commissions_on_commission_id                  (commission_id)
#  index_positions_commissions_on_position_id                    (position_id)
#  index_positions_commissions_on_position_id_and_commission_id  (position_id,commission_id) UNIQUE
#

class PositionsCommission < ApplicationRecord
	belongs_to :position
	belongs_to :commission, optional: true
end
