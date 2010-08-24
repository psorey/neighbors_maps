require 'test_helper'

class TeamMembersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:team_members)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create team_member" do
    assert_difference('TeamMember.count') do
      post :create, :team_member => { }
    end

    assert_redirected_to team_member_path(assigns(:team_member))
  end

  test "should show team_member" do
    get :show, :id => team_members(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => team_members(:one).to_param
    assert_response :success
  end

  test "should update team_member" do
    put :update, :id => team_members(:one).to_param, :team_member => { }
    assert_redirected_to team_member_path(assigns(:team_member))
  end

  test "should destroy team_member" do
    assert_difference('TeamMember.count', -1) do
      delete :destroy, :id => team_members(:one).to_param
    end

    assert_redirected_to team_members_path
  end
end
