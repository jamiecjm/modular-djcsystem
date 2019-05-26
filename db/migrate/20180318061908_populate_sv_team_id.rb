class PopulateSvTeamId < ActiveRecord::Migration[5.1]
  def up
    return
    Salevalue.all.each { |sv|
      next if sv.user_id.nil?
      user = User.find(sv.user_id)
      sv.update_column(:team_id, user&.current_team&.id)
    }
  end

  def down
  end
end
