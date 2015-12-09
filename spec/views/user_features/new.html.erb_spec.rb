require 'rails_helper'

RSpec.describe "user_features/new", type: :view do
  before(:each) do
    assign(:user_feature, UserFeature.new(
      :map_layer_id => 1,
      :user_id => 1,
      :name => "MyString",
      :text => "MyText",
      :number => 1,
      :amount => 1.5
    ))
  end

  it "renders new user_feature form" do
    render

    assert_select "form[action=?][method=?]", user_features_path, "post" do

      assert_select "input#user_feature_map_layer_id[name=?]", "user_feature[map_layer_id]"

      assert_select "input#user_feature_user_id[name=?]", "user_feature[user_id]"

      assert_select "input#user_feature_name[name=?]", "user_feature[name]"

      assert_select "textarea#user_feature_text[name=?]", "user_feature[text]"

      assert_select "input#user_feature_number[name=?]", "user_feature[number]"

      assert_select "input#user_feature_amount[name=?]", "user_feature[amount]"
    end
  end
end
