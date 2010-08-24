require 'test_helper'

class HalfBlocksControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:half_blocks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create half_block" do
    assert_difference('HalfBlock.count') do
      post :create, :half_block => { }
    end

    assert_redirected_to half_block_path(assigns(:half_block))
  end

  test "should show half_block" do
    get :show, :id => half_blocks(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => half_blocks(:one).to_param
    assert_response :success
  end

  test "should update half_block" do
    put :update, :id => half_blocks(:one).to_param, :half_block => { }
    assert_redirected_to half_block_path(assigns(:half_block))
  end

  test "should destroy half_block" do
    assert_difference('HalfBlock.count', -1) do
      delete :destroy, :id => half_blocks(:one).to_param
    end

    assert_redirected_to half_blocks_path
  end
end
