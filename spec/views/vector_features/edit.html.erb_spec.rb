require 'rails_helper'

RSpec.describe "vector_features/edit", type: :view do
  before(:each) do
    @vector_feature = assign(:vector_feature, VectorFeature.create!(
      :name => "MyString",
      :text => "MyText",
      :vector_type => "MyString",
      :amount => 1.5,
      :number => 1,
      :guid => "MyString"
    ))
  end

  it "renders the edit vector_feature form" do
    render

    assert_select "form[action=?][method=?]", vector_feature_path(@vector_feature), "post" do

      assert_select "input#vector_feature_name[name=?]", "vector_feature[name]"

      assert_select "textarea#vector_feature_text[name=?]", "vector_feature[text]"

      assert_select "input#vector_feature_vector_type[name=?]", "vector_feature[vector_type]"

      assert_select "input#vector_feature_amount[name=?]", "vector_feature[amount]"

      assert_select "input#vector_feature_number[name=?]", "vector_feature[number]"

      assert_select "input#vector_feature_guid[name=?]", "vector_feature[guid]"
    end
  end
end
