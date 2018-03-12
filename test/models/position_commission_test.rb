# == Schema Information
#
# Table name: position_commissions
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
#  index_position_commissions_on_commission_id                  (commission_id)
#  index_position_commissions_on_position_id                    (position_id)
#  index_position_commissions_on_position_id_and_commission_id  (position_id,commission_id) UNIQUE
#

require 'test_helper'

class PositionCommissionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
