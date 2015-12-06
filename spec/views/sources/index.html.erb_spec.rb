require 'rails_helper'

RSpec.describe "sources/index", type: :view do
  before(:each) do
    assign(:sources, [
      Source.create!(
        :url => "Url",
        :wms_params => "Wms Params",
        :source_type => "Source Type",
        :layer => "Layer",
        :server_type => "Server Type"
      ),
      Source.create!(
        :url => "Url",
        :wms_params => "Wms Params",
        :source_type => "Source Type",
        :layer => "Layer",
        :server_type => "Server Type"
      )
    ])
  end

  it "renders a list of sources" do
    render
    assert_select "tr>td", :text => "Url".to_s, :count => 2
    assert_select "tr>td", :text => "Wms Params".to_s, :count => 2
    assert_select "tr>td", :text => "Source Type".to_s, :count => 2
    assert_select "tr>td", :text => "Layer".to_s, :count => 2
    assert_select "tr>td", :text => "Server Type".to_s, :count => 2
  end
end
