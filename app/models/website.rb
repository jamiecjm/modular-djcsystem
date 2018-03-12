# == Schema Information
#
# Table name: public.websites
#
#  id              :integer          not null, primary key
#  subdomain       :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  superteam_name  :string
#  logo            :string
#  external_host   :string
#  email           :string
#  password        :string
#  password_digest :string
#

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
