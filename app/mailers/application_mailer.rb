class ApplicationMailer < ActionMailer::Base
  default from: proc{
	host = ActionMailer::Base.default_url_options[:host]
  	subdomain = ActionMailer::Base.default_url_options[:host].split('.')[0]
	website = Website.find_by(external_host: host)
	if website.nil?
		if subdomain == 'www'
		  	return nil
		else
		  	website = Website.find_by(subdomain: subdomain)
		end
	end  
	website.email
  }
  layout 'mailer'
end
