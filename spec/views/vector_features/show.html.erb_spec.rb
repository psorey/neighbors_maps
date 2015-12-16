require 'rails_helper'

RSpec.describe "vector_features/show", type: :view do
  before(:each) do
    @vector_feature = assign(:vector_feature, VectorFeature.create!(
      :name => "Name",
      :text => "MyText",
      :vector_type => "Vector Type",
      :amount => 1.5,
      :number => 1,
      :guid => "Guid"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Vector Type/)
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Guid/)
  end
end
