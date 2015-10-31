require 'rails_helper'

RSpec.describe "features/show", :type => :view do
  before(:each) do
    @feature = assign(:feature, Feature.create!(
      :name => "Name",
      :guid => "Guid",
      :user_id => 1,
      :share_type_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Guid/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
  end
end
