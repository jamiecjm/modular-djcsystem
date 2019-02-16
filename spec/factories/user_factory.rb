# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string
#  encrypted_password     :string
#  name                   :string
#  prefered_name          :string           not null
#  phone_no               :string
#  birthday               :date
#  team_id                :integer
#  ancestry               :string
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  admin                  :boolean          default(FALSE)
#  archived               :boolean          default(FALSE)
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  locked_at              :datetime
#  ic_no                  :string
#  location               :string
#  referrer_id            :integer
#  upline_id              :integer
#
# Indexes
#
#  index_users_on_ancestry              (ancestry)
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_prefered_name         (prefered_name)
#  index_users_on_referrer_id           (referrer_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_team_id               (team_id)
#  index_users_on_upline_id             (upline_id)
#

# FactoryBot.define do
#   factory :admin, class: 'User' do
#     email 'admin@gmail.com'
#     name 'admin'
#     prefered_name 'admin'
#     phone_no '123'
#     ancestry nil
#     admin true
#     password 123456
#   end
#
#   factory :root, class: 'User' do
#     # association :children, factory: :children1, strategy: :build
#     # association :children, factory: :children2, strategy: :build
#     email 'root@gmail.com'
#     name 'root'
#     prefered_name 'root'
#     phone_no '123'
#     ancestry nil
#     location 'KL'
#     password 123456
#   end
#
#   factory :children1, class: 'User' do
#     email 'children1@gmail.com'
#     name 'children1'
#     prefered_name 'children1'
#     phone_no '123'
#     location 'KL'
#     password 123456
#   end
#
#   factory :children2, class: 'User' do
#     email 'children2@gmail.com'
#     name 'children2'
#     prefered_name 'children2'
#     phone_no '123'
#     location 'KL'
#     password 123456
#   end
#
#   factory :grandchildren1, class: 'User' do
#     email 'grandchildren1@gmail.com'
#     name 'grandchildren1'
#     prefered_name 'grandchildren1'
#     phone_no '123'
#     location 'KL'
#     password 123456
#   end
#
#   factory :grandchildren2, class: 'User' do
#     email 'grandchildren2@gmail.com'
#     name 'grandchildren2'
#     prefered_name 'grandchildren2'
#     phone_no '123'
#     location 'KL'
#     password 123456
#   end
#
#   factory :grandchildren3, class: 'User' do
#     email 'grandchildren3@gmail.com'
#     name 'grandchildren3'
#     prefered_name 'grandchildren3'
#     phone_no '123'
#     location 'KL'
#     password 123456
#   end
#
#   factory :grandchildren4, class: 'User' do
#     email 'grandchildren4@gmail.com'
#     name 'grandchildren4'
#     prefered_name 'grandchildren4'
#     phone_no '123'
#     location 'KL'
#     password 123456
#   end
#
#   factory :user_without_email, class: 'User' do
#     # association :children, factory: :children1, strategy: :build
#     # association :children, factory: :children2, strategy: :build
#     name 'root'
#     prefered_name 'root'
#     phone_no '123'
#     ancestry nil
#     location 'KL'
#     password 123456
#   end
#
#   factory :user_without_name, class: 'User' do
#     # association :children, factory: :children1, strategy: :build
#     # association :children, factory: :children2, strategy: :build
#     email 'root@gmail.com'
#     prefered_name 'root'
#     phone_no '123'
#     ancestry nil
#     location 'KL'
#     password 123456
#   end
#
#   factory :user_without_prefered_name, class: 'User' do
#     # association :children, factory: :children1, strategy: :build
#     # association :children, factory: :children2, strategy: :build
#     email 'root@gmail.com'
#     name 'root'
#     phone_no '123'
#     ancestry nil
#     location 'KL'
#     password 123456
#   end
#
#   factory :user_without_location, class: 'User' do
#     # association :children, factory: :children1, strategy: :build
#     # association :children, factory: :children2, strategy: :build
#     email 'root@gmail.com'
#     name 'root'
#     prefered_name 'root'
#     phone_no '123'
#     ancestry nil
#     password 123456
#   end
#
#   factory :user_without_password, class: 'User' do
#     # association :children, factory: :children1, strategy: :build
#     # association :children, factory: :children2, strategy: :build
#     email 'root@gmail.com'
#     name 'root'
#     prefered_name 'root'
#     phone_no '123'
#     ancestry nil
#     location 'KL'
#   end
# end
