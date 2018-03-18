require 'rails_helper'

RSpec.describe "Sessions", type: :request do

	describe "GET /login" do
		it "should not return error" do
			get new_user_session_path
			expect(response).to have_http_status(200)
		end
	end
end
