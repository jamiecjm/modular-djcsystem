# == Schema Information
#
# Table name: overridings
#
#  id           :integer          not null, primary key
#  team_id      :integer
#  salevalue_id :integer
#  override     :float
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_overridings_on_salevalue_id              (salevalue_id)
#  index_overridings_on_team_id                   (team_id)
#  index_overridings_on_team_id_and_salevalue_id  (team_id,salevalue_id) UNIQUE
#

require 'test_helper'

class OverridingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
