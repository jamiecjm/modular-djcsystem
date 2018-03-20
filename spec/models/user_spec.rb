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
#

require 'rails_helper'

RSpec.describe User, type: :model do
	context 'created' do
		it 'is valid with email, name, prefered_name and location' do
			user = FactoryBot.build(:user_without_email)
			user.email = 'abc@gmail.com'
			expect(user).to be_valid
		end

		it 'is not valid without an email' do
			expect(FactoryBot.build(:user_without_email)).to be_invalid
		end

		it 'is not valid without a name' do
			expect(FactoryBot.build(:user_without_name)).to be_invalid
		end

		it 'is not valid without a prefered_name' do
			expect(FactoryBot.build(:user_without_prefered_name)).to be_invalid
		end

		it 'must have unique prefered_name' do
			FactoryBot.create(:root)
			expect(FactoryBot.build(:root)).to be_invalid
		end

		it 'is not valid without a location' do
			expect(FactoryBot.build(:user_without_location)).to be_invalid
		end

		it 'automatically creates a team' do
			user = FactoryBot.create(:root)
			expect(user.teams.length).to eq(1)
		end

		it 'automatically sets referrer id' do
			user = FactoryBot.create(:root)
			children = FactoryBot.build(:children1)
			children.parent = user
			children.save
			expect(children.referrer_id).to eq(user.id)
		end

		it 'has empty referrer_id if root' do
			user = FactoryBot.create(:root)
			expect(user.referrer_id).to eq(nil)
		end

		it 'automatically locks itself' do
			user = FactoryBot.create(:root)
			expect(user.locked_at?).to be_truthy
		end
	end

	context 'created as admin' do
		it 'is not valid without an email' do
			admin = FactoryBot.build(:admin)
			admin.email = nil
			expect(admin).to be_invalid
		end

		it 'is not valid without a name' do
			admin = FactoryBot.build(:admin)
			admin.name = nil
			expect(admin).to be_invalid
		end

		it 'is not valid without a prefered_name' do
			admin = FactoryBot.build(:admin)
			admin.prefered_name = nil
			expect(admin).to be_invalid
		end

		it 'must have unique prefered_name' do
			FactoryBot.create(:admin)
			admin = FactoryBot.build(:admin)
			expect(admin).to be_invalid
		end

		it 'is valid without a location' do
			admin = FactoryBot.build(:admin)
			admin.location = nil
			expect(admin).to be_valid
		end

		it 'automatically creates a team' do
			user = FactoryBot.create(:admin)
			expect(user.teams.length).to eq(1)
		end

		it 'automatically sets referrer id' do
			user = FactoryBot.create(:root)
			children = FactoryBot.build(:admin)
			children.parent = user
			children.save
			expect(children.referrer_id).to eq(user.id)
		end

		it 'does not automatically lock itself' do
			user = FactoryBot.create(:admin)
			expect(user.locked_at?).to be_falsy
		end		
	end

	context 'with 1 team' do
		before do
			admin = FactoryBot.create(:admin)
			root = FactoryBot.create(:root)
			children1 = FactoryBot.build(:children1)
			children1.parent = root
			children1.save
			children2 = FactoryBot.build(:children2)
			children2.parent = root
			children2.save
			grandchildren1 = FactoryBot.build(:grandchildren1)
			grandchildren1.parent = children1
			grandchildren1.save
			grandchildren2 = FactoryBot.build(:grandchildren2)
			grandchildren2.parent = children1
			grandchildren2.save
			grandchildren3 = FactoryBot.build(:grandchildren3)
			grandchildren3.parent = children2
			grandchildren3.save
			grandchildren4 = FactoryBot.build(:grandchildren4)
			grandchildren4.parent = children2
			grandchildren4.save
		end

		it 'has 7 current_team_members' do
			root = User.find_by(name: 'Root')
			expect(root.current_team_members.length).to eq(7)
		end

		it 'has 7 all_team_subtree' do
			root = User.find_by(name: 'Root')
			expect(root.all_team_subtree.length).to eq(7)
		end
	end

	context 'becomes inactive' do
		before do
			admin = FactoryBot.create(:admin)
			root = FactoryBot.create(:root)
			root.current_team.update(effective_date: 1.month.ago)
			children1 = FactoryBot.build(:children1)
			children1.parent = root
			children1.save
			children2 = FactoryBot.build(:children2)
			children2.parent = root
			children2.save
			grandchildren1 = FactoryBot.build(:grandchildren1)
			grandchildren1.parent = children1
			grandchildren1.save
			grandchildren2 = FactoryBot.build(:grandchildren2)
			grandchildren2.parent = children1
			grandchildren2.save
			grandchildren3 = FactoryBot.build(:grandchildren3)
			grandchildren3.parent = children2
			grandchildren3.save
			grandchildren4 = FactoryBot.build(:grandchildren4)
			grandchildren4.parent = children2
			grandchildren4.save
			Team.create(user_id: root.id, position_id: nil, effective_date: Date.today)
		end

		it 'has 1 current_team_members' do
			root = User.find_by(name: 'Root')
			expect(root.current_team_members.length).to eq(1)
		end

		it 'has 8 all_team_subtree' do
			root = User.find_by(name: 'Root')
			byebug
			expect(root.all_team_subtree.length).to eq(8)
		end
	end
end
