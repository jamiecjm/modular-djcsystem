require 'rails_helper'

RSpec.describe "Teams", type: :request do
	before do
		user = FactoryBot.create(:root)
		user.confirm
		user.unlock_access!
		sign_in user
	end
	describe "GET /teams" do
		it "should not return error" do
			get teams_path
			expect(response).to have_http_status(200)
		end
	end
end
