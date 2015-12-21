require 'rails_helper'

RSpec.describe "ol3_vector_styles/show", type: :view do
  before(:each) do
    @ol3_vector_style = assign(:ol3_vector_style, Ol3VectorStyle.create!(
      :name => "Name",
      :alias => "Alias",
      :stroke_width => 1.5,
      :font_size => 1.5,
      :stroke_color => "Stroke Color",
      :font_color => "Font Color",
      :fill_color => "Fill Color",
      :style_type => "Style Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Alias/)
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(/Stroke Color/)
    expect(rendered).to match(/Font Color/)
    expect(rendered).to match(/Fill Color/)
    expect(rendered).to match(/Style Type/)
  end
end
