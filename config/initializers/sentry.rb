if Rails.env.production?
	Raven.configure do |config|
		config.dsn = "https://#{ENV['sentry_key']}:#{ENV['sentry_secret']}@sentry.io/298281"
	  	config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
	end
end