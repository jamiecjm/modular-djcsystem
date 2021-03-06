# == Schema Information
#
# Table name: teams
#
#  id             :integer          not null, primary key
#  name           :string
#  user_id        :integer
#  ancestry       :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  effective_date :date
#  position_id    :integer
#  upline_id      :integer
#  hidden         :boolean          default(FALSE)
#  current        :boolean          default(TRUE)
#
# Indexes
#
#  index_teams_on_ancestry   (ancestry)
#  index_teams_on_upline_id  (upline_id)
#  index_teams_on_user_id    (user_id)
#

require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
