require 'rails_helper'

RSpec.describe "vector_features/index", type: :view do
  before(:each) do
    assign(:vector_features, [
      VectorFeature.create!(
        :name => "Name",
        :text => "MyText",
        :vector_type => "Vector Type",
        :amount => 1.5,
        :number => 1,
        :guid => "Guid"
      ),
      VectorFeature.create!(
        :name => "Name",
        :text => "MyText",
        :vector_type => "Vector Type",
        :amount => 1.5,
        :number => 1,
        :guid => "Guid"
      )
    ])
  end

  it "renders a list of vector_features" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Vector Type".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Guid".to_s, :count => 2
  end
end
