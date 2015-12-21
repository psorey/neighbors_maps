require "rails_helper"

RSpec.describe Ol3VectorStylesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/ol3_vector_styles").to route_to("ol3_vector_styles#index")
    end

    it "routes to #new" do
      expect(:get => "/ol3_vector_styles/new").to route_to("ol3_vector_styles#new")
    end

    it "routes to #show" do
      expect(:get => "/ol3_vector_styles/1").to route_to("ol3_vector_styles#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/ol3_vector_styles/1/edit").to route_to("ol3_vector_styles#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/ol3_vector_styles").to route_to("ol3_vector_styles#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/ol3_vector_styles/1").to route_to("ol3_vector_styles#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/ol3_vector_styles/1").to route_to("ol3_vector_styles#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/ol3_vector_styles/1").to route_to("ol3_vector_styles#destroy", :id => "1")
    end

  end
end
