class ApplicationMailer < ActionMailer::Base
  default from: "DJC System <no-reply@djcsystem.com>"
  defatul return_path: ENV["DEV_EMAIL"]
  layout "mailer"
end
