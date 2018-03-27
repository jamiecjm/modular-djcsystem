class ChangeTeamEffectiveDate < ActiveRecord::Migration[5.1]
  def up
	Team.find_each do |t|
	  date = t.parent&.effective_date
	  date ||= '2000-1-1'
	  t.update_columns(effective_date: date)
	end  
  end

  def down
  end
end
