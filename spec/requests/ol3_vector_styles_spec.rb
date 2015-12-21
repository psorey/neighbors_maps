require 'rails_helper'

RSpec.describe "Ol3VectorStyles", type: :request do
  describe "GET /ol3_vector_styles" do
    it "works! (now write some real specs)" do
      get ol3_vector_styles_path
      expect(response).to have_http_status(200)
    end
  end
end
