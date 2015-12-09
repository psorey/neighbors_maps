require 'rails_helper'

RSpec.describe "UserFeatures", type: :request do
  describe "GET /user_features" do
    it "works! (now write some real specs)" do
      get user_features_path
      expect(response).to have_http_status(200)
    end
  end
end
