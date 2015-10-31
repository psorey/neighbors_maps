require 'rails_helper'

RSpec.describe "features/index", :type => :view do
  before(:each) do
    assign(:features, [
      Feature.create!(
        :name => "Name",
        :guid => "Guid",
        :user_id => 1,
        :share_type_id => 2
      ),
      Feature.create!(
        :name => "Name",
        :guid => "Guid",
        :user_id => 1,
        :share_type_id => 2
      )
    ])
  end

  it "renders a list of features" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Guid".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
