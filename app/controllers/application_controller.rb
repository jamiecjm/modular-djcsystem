class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception

	include LocalSubdomain

	helper_method :current_website

	def access_denied(exception)
		redirect_to root_path, alert: exception.message
	end

	def current_website
		website = Website.find_by(external_host: request.host)
		if website.nil?
			subdomain = request.host.split('.')[0]
			if subdomain == 'www'
			  	return nil
			else
			  	website = Website.find_by(subdomain: subdomain)
			end
		end  
		return website 	
	end

end
