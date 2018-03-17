module ActiveAdmin::ViewsHelper #camelized file name
	def current_website
		Website.find(Apartment::Tenant.current)
	end
end