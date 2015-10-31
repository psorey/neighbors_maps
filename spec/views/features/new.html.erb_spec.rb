require 'rails_helper'

RSpec.describe "features/new", :type => :view do
  before(:each) do
    assign(:feature, Feature.new(
      :name => "MyString",
      :guid => "MyString",
      :user_id => 1,
      :share_type_id => 1
    ))
  end

  it "renders new feature form" do
    render

    assert_select "form[action=?][method=?]", features_path, "post" do

      assert_select "input#feature_name[name=?]", "feature[name]"

      assert_select "input#feature_guid[name=?]", "feature[guid]"

      assert_select "input#feature_user_id[name=?]", "feature[user_id]"

      assert_select "input#feature_share_type_id[name=?]", "feature[share_type_id]"
    end
  end
end
