require "rails_helper"

RSpec.describe VectorFeaturesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/vector_features").to route_to("vector_features#index")
    end

    it "routes to #new" do
      expect(:get => "/vector_features/new").to route_to("vector_features#new")
    end

    it "routes to #show" do
      expect(:get => "/vector_features/1").to route_to("vector_features#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/vector_features/1/edit").to route_to("vector_features#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/vector_features").to route_to("vector_features#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/vector_features/1").to route_to("vector_features#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/vector_features/1").to route_to("vector_features#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/vector_features/1").to route_to("vector_features#destroy", :id => "1")
    end

  end
end
