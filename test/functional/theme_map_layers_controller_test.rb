require 'test_helper'

class ThemeMapLayersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:theme_map_layers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create theme_map_layer" do
    assert_difference('ThemeMapLayer.count') do
      post :create, :theme_map_layer => { }
    end

    assert_redirected_to theme_map_layer_path(assigns(:theme_map_layer))
  end

  test "should show theme_map_layer" do
    get :show, :id => theme_map_layers(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => theme_map_layers(:one).to_param
    assert_response :success
  end

  test "should update theme_map_layer" do
    put :update, :id => theme_map_layers(:one).to_param, :theme_map_layer => { }
    assert_redirected_to theme_map_layer_path(assigns(:theme_map_layer))
  end

  test "should destroy theme_map_layer" do
    assert_difference('ThemeMapLayer.count', -1) do
      delete :destroy, :id => theme_map_layers(:one).to_param
    end

    assert_redirected_to theme_map_layers_path
  end
end
