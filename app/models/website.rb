class Website < ApplicationRecord

	mount_uploader :logo, LogoUploader

	attr_accessor :logo_cache

	validates :email, presence: true
	validates :subdomain, uniqueness: true
	validates :external_host, uniqueness: true

	def display_name
		superteam_name
	end

end
