class ApplicationMailer < ActionMailer::Base
  default from: "DJC System <no-reply@djcsystem.com>"
  default return_path: ENV["DEV_EMAIL"]
  layout "mailer"
end
