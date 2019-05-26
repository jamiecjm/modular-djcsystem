class RenameUserIdToTeamId < ActiveRecord::Migration[5.1]
  def up
    add_column :salevalues, :team_id, :integer if !column_exists?(:salevalues, :team_id)
    return
    Salevalue.all.each { |sv|
      sv.update_column(:team_id, sv.user&.team&.id)
    }
  end

  def down
    remove_column :salevalues, :team_id
  end
end
