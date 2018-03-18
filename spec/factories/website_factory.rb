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

FactoryBot.define do
  factory :website do
    subdomain 'eliteone'
    superteam_name 'Eliteone'
    logo 'image/upload/v1520436779/wwkyta9njde1rjh0wpn7.png'
    external_host 'www.eliteonegroup.com'
    email 'website@email.com'
  end
end
