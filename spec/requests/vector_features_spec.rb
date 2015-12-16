require 'rails_helper'

RSpec.describe "VectorFeatures", type: :request do
  describe "GET /vector_features" do
    it "works! (now write some real specs)" do
      get vector_features_path
      expect(response).to have_http_status(200)
    end
  end
end
