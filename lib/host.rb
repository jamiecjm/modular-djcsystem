class Host
  def self.matches?(request)
    ['www.djcsystem.com', 'www.lvh.me:3000'].include?(request.host_with_port)
  end
end