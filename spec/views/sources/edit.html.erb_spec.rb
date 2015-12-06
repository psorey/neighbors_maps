require 'rails_helper'

RSpec.describe "sources/edit", type: :view do
  before(:each) do
    @source = assign(:source, Source.create!(
      :url => "MyString",
      :wms_params => "MyString",
      :source_type => "MyString",
      :layer => "MyString",
      :server_type => "MyString"
    ))
  end

  it "renders the edit source form" do
    render

    assert_select "form[action=?][method=?]", source_path(@source), "post" do

      assert_select "input#source_url[name=?]", "source[url]"

      assert_select "input#source_wms_params[name=?]", "source[wms_params]"

      assert_select "input#source_source_type[name=?]", "source[source_type]"

      assert_select "input#source_layer[name=?]", "source[layer]"

      assert_select "input#source_server_type[name=?]", "source[server_type]"
    end
  end
end
