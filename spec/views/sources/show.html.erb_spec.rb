require 'rails_helper'

RSpec.describe "sources/show", type: :view do
  before(:each) do
    @source = assign(:source, Source.create!(
      :url => "Url",
      :wms_params => "Wms Params",
      :source_type => "Source Type",
      :layer => "Layer",
      :server_type => "Server Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Url/)
    expect(rendered).to match(/Wms Params/)
    expect(rendered).to match(/Source Type/)
    expect(rendered).to match(/Layer/)
    expect(rendered).to match(/Server Type/)
  end
end
