FactoryBot.define do
  factory :admin, class: 'User' do
    email 'admin@gmail.com'
    name 'admin'
    prefered_name 'admin'
    phone_no '123'
    ancestry nil
    admin true
    archived false
    location 'KL'
    referrer_id nil
    password 123456
  end

  # This will use the User class (Admin would have been guessed)
  factory :user do
    email 'user@gmail.com'
    name 'user'
    prefered_name 'user'
    phone_no '123'
    ancestry nil
    admin false
    archived false
    location 'KL'
    referrer_id 1
    password 123456
  end
end