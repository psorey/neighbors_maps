require 'rails_helper'

RSpec.describe "user_features/show", type: :view do
  before(:each) do
    @user_feature = assign(:user_feature, UserFeature.create!(
      :map_layer_id => 1,
      :user_id => 2,
      :name => "Name",
      :text => "MyText",
      :number => 3,
      :amount => 1.5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/1.5/)
  end
end
