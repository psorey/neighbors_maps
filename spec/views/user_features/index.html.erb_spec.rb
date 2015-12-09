require 'rails_helper'

RSpec.describe "user_features/index", type: :view do
  before(:each) do
    assign(:user_features, [
      UserFeature.create!(
        :map_layer_id => 1,
        :user_id => 2,
        :name => "Name",
        :text => "MyText",
        :number => 3,
        :amount => 1.5
      ),
      UserFeature.create!(
        :map_layer_id => 1,
        :user_id => 2,
        :name => "Name",
        :text => "MyText",
        :number => 3,
        :amount => 1.5
      )
    ])
  end

  it "renders a list of user_features" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
  end
end
