class ApplicationMailer < ActionMailer::Base
  default from: proc{
  	subdomain = ActionMailer::Base.default_url_options[:host].split('.')[0]
  	website = Website.find_by(subdomain: subdomain)
  	website.email
  }
  layout 'mailer'
end
