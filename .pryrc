ActiveRecord::Base.connection.schema_search_path = 2
begin
  require 'awesome_print'
  AwesomePrint.defaults = {
    indent: -2, # left aligned
    sort_keys: true, # sort hash keys
    # more customization
  }
  Pry.config.print = proc { |output, value| Pry::Helpers::BaseHelpers.stagger_output("=> #{value.ai}", output) }
rescue LoadError => err
  puts "no awesome_print :("
end