require 'rails_helper'

RSpec.describe "ol3_vector_styles/edit", type: :view do
  before(:each) do
    @ol3_vector_style = assign(:ol3_vector_style, Ol3VectorStyle.create!(
      :name => "MyString",
      :alias => "MyString",
      :stroke_width => 1.5,
      :font_size => 1.5,
      :stroke_color => "MyString",
      :font_color => "MyString",
      :fill_color => "MyString",
      :style_type => "MyString"
    ))
  end

  it "renders the edit ol3_vector_style form" do
    render

    assert_select "form[action=?][method=?]", ol3_vector_style_path(@ol3_vector_style), "post" do

      assert_select "input#ol3_vector_style_name[name=?]", "ol3_vector_style[name]"

      assert_select "input#ol3_vector_style_alias[name=?]", "ol3_vector_style[alias]"

      assert_select "input#ol3_vector_style_stroke_width[name=?]", "ol3_vector_style[stroke_width]"

      assert_select "input#ol3_vector_style_font_size[name=?]", "ol3_vector_style[font_size]"

      assert_select "input#ol3_vector_style_stroke_color[name=?]", "ol3_vector_style[stroke_color]"

      assert_select "input#ol3_vector_style_font_color[name=?]", "ol3_vector_style[font_color]"

      assert_select "input#ol3_vector_style_fill_color[name=?]", "ol3_vector_style[fill_color]"

      assert_select "input#ol3_vector_style_style_type[name=?]", "ol3_vector_style[style_type]"
    end
  end
end
