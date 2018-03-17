module Macros
  module Global
    def submit_form
      find('input[name="commit"]').click
    end
  end
end