# == Schema Information
#
# Table name: salevalues
#
#  id         :integer          not null, primary key
#  percentage :float
#  nett_value :float
#  spa        :float
#  comm       :float
#  user_id    :integer
#  sale_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  order      :integer
#  other_user :string
#  team_id    :integer
#
# Indexes
#
#  index_salevalues_on_sale_id  (sale_id)
#  index_salevalues_on_user_id  (user_id)
#

require 'test_helper'

class SalevalueTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
