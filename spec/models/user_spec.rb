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
		it 'is not valid without a name' do
			# expect(FactoryBot.new(:user_without_name)).to be_invalid
		end

		it 'automatically creates a team' do
			user = FactoryBot.create(:root)
			expect(user.teams.length).to eq(1)
		end

		it 'automatically sets referrer id' do

		end

		it 'automatically locks itself' do
			user = FactoryBot.create(:root)
			expect(user.locked_at?).to be_truthy
		end
	end
end
