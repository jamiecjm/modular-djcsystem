class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception

	include LocalSubdomain

	helper_method :current_website
	before_action :set_raven_context, if: proc{ Rails.env.production? }
	unless Rails.application.config.consider_all_requests_local
		rescue_from ActionController::RoutingError, with: -> { redirect_to_root  }
		rescue_from ActionController::UnknownController, with: -> { redirect_to_root  }
		rescue_from ActiveRecord::RecordNotFound,        with: -> { redirect_to_root  }
	end

	protected

	def access_denied(exception)
		redirect_to root_path, alert: exception.message
	end

	def denied
		redirect_to root_path, alert: 'You are not authorized to perform this action.'
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
		website 
	end

	def set_mailer_host
		ActionMailer::Base.default_url_options[:host] = request.host_with_port
	end
	
	private

	def set_raven_context
		Raven.user_context(id: current_user&.id, email: current_user&.email, prefered_name: current_user&.prefered_name) # or anything else in session
		Raven.extra_context(params: params.to_unsafe_h, url: request.url)
	end

	def redirect_to_root
	  redirect_to root_path
	end
end
