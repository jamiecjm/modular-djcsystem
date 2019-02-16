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

require 'test_helper'

class PositionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
