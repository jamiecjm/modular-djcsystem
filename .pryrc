ActiveRecord::Base.connection.schema_search_path = 2
Pry.config.history.file = "#{ENV['HOME']}/.pry_history"
Pry.config.history.should_save = true
Pry.config.history.should_load = true
Pry.history.load