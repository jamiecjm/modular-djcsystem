class Subdomain
	def self.matches?(request)
		request.subdomain.present? &&  !['www.djcsystem.com', 'www.lvh.me:3000'].include?(request.host_with_port)
	end
end