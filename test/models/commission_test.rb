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

require 'test_helper'

class CommissionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
