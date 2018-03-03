class Website < ApplicationRecord

	mount_uploader :logo, LogoUploader

	validates :email, presence: true
	validates :subdomain, uniqueness: true
	validates :external_host, uniqueness: true

end
