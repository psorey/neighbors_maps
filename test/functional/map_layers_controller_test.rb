require 'test_helper'

class MapLayersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:map_layers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create map_layer" do
    assert_difference('MapLayer.count') do
      post :create, :map_layer => { }
    end

    assert_redirected_to map_layer_path(assigns(:map_layer))
  end

  test "should show map_layer" do
    get :show, :id => map_layers(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => map_layers(:one).to_param
    assert_response :success
  end

  test "should update map_layer" do
    put :update, :id => map_layers(:one).to_param, :map_layer => { }
    assert_redirected_to map_layer_path(assigns(:map_layer))
  end

  test "should destroy map_layer" do
    assert_difference('MapLayer.count', -1) do
      delete :destroy, :id => map_layers(:one).to_param
    end

    assert_redirected_to map_layers_path
  end
end
