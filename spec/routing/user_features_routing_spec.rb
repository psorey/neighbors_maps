require "rails_helper"

RSpec.describe UserFeaturesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/user_features").to route_to("user_features#index")
    end

    it "routes to #new" do
      expect(:get => "/user_features/new").to route_to("user_features#new")
    end

    it "routes to #show" do
      expect(:get => "/user_features/1").to route_to("user_features#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/user_features/1/edit").to route_to("user_features#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/user_features").to route_to("user_features#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/user_features/1").to route_to("user_features#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/user_features/1").to route_to("user_features#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/user_features/1").to route_to("user_features#destroy", :id => "1")
    end

  end
end
