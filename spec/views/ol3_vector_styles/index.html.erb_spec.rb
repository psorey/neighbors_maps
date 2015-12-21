require 'rails_helper'

RSpec.describe "ol3_vector_styles/index", type: :view do
  before(:each) do
    assign(:ol3_vector_styles, [
      Ol3VectorStyle.create!(
        :name => "Name",
        :alias => "Alias",
        :stroke_width => 1.5,
        :font_size => 1.5,
        :stroke_color => "Stroke Color",
        :font_color => "Font Color",
        :fill_color => "Fill Color",
        :style_type => "Style Type"
      ),
      Ol3VectorStyle.create!(
        :name => "Name",
        :alias => "Alias",
        :stroke_width => 1.5,
        :font_size => 1.5,
        :stroke_color => "Stroke Color",
        :font_color => "Font Color",
        :fill_color => "Fill Color",
        :style_type => "Style Type"
      )
    ])
  end

  it "renders a list of ol3_vector_styles" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Alias".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => "Stroke Color".to_s, :count => 2
    assert_select "tr>td", :text => "Font Color".to_s, :count => 2
    assert_select "tr>td", :text => "Fill Color".to_s, :count => 2
    assert_select "tr>td", :text => "Style Type".to_s, :count => 2
  end
end
