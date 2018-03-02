module ActiveAdmin::ViewsHelper #camelized file name
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