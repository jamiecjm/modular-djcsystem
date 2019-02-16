# == Schema Information
#
# Table name: positions_commissions
#
#  id            :bigint(8)        not null, primary key
#  position_id   :integer
#  commission_id :integer
#  percentage    :float
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_positions_commissions_on_commission_id                  (commission_id)
#  index_positions_commissions_on_position_id                    (position_id)
#  index_positions_commissions_on_position_id_and_commission_id  (position_id,commission_id) UNIQUE
#

require 'test_helper'

class PositionsCommissionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
