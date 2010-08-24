require 'test_helper'

class HouseholdsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:households)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create household" do
    assert_difference('Household.count') do
      post :create, :household => { }
    end

    assert_redirected_to household_path(assigns(:household))
  end

  test "should show household" do
    get :show, :id => households(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => households(:one).to_param
    assert_response :success
  end

  test "should update household" do
    put :update, :id => households(:one).to_param, :household => { }
    assert_redirected_to household_path(assigns(:household))
  end

  test "should destroy household" do
    assert_difference('Household.count', -1) do
      delete :destroy, :id => households(:one).to_param
    end

    assert_redirected_to households_path
  end
end
