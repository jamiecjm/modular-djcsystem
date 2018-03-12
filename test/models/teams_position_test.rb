# == Schema Information
#
# Table name: teams_positions
#
#  id             :integer          not null, primary key
#  team_id        :integer
#  position_id    :integer
#  effective_date :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_teams_positions_on_position_id              (position_id)
#  index_teams_positions_on_team_id                  (team_id)
#  index_teams_positions_on_team_id_and_position_id  (team_id,position_id) UNIQUE
#

require 'test_helper'

class TeamsPositionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
