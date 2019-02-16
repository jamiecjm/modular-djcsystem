class RenameTenantName < ActiveRecord::Migration[5.1]
  def up
    # execute('ALTER SCHEMA "2" RENAME TO eliteone')
    # execute('ALTER SCHEMA "3" RENAME TO legacy')
  end

  def down
    # execute('ALTER SCHEMA eliteone RENAME TO "2"')
    # execute('ALTER SCHEMA legacy RENAME TO "3"')
  end
end
