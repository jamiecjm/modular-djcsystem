# == Schema Information
#
# Table name: position_commissions
#
#  id            :integer          not null, primary key
#  position_id   :integer
#  commission_id :integer
#  percentage    :float
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_position_commissions_on_commission_id                  (commission_id)
#  index_position_commissions_on_position_id                    (position_id)
#  index_position_commissions_on_position_id_and_commission_id  (position_id,commission_id) UNIQUE
#

class PositionCommission < ApplicationRecord

end
