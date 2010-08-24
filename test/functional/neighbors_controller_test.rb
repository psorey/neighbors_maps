require 'test_helper'

class NeighborsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:neighbors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create neighbor" do
    assert_difference('Neighbor.count') do
      post :create, :neighbor => { }
    end

    assert_redirected_to neighbor_path(assigns(:neighbor))
  end

  test "should show neighbor" do
    get :show, :id => neighbors(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => neighbors(:one).to_param
    assert_response :success
  end

  test "should update neighbor" do
    put :update, :id => neighbors(:one).to_param, :neighbor => { }
    assert_redirected_to neighbor_path(assigns(:neighbor))
  end

  test "should destroy neighbor" do
    assert_difference('Neighbor.count', -1) do
      delete :destroy, :id => neighbors(:one).to_param
    end

    assert_redirected_to neighbors_path
  end
end
