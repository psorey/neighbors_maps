require 'test_helper'

class ThemeMapsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:theme_maps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create theme_map" do
    assert_difference('ThemeMap.count') do
      post :create, :theme_map => { }
    end

    assert_redirected_to theme_map_path(assigns(:theme_map))
  end

  test "should show theme_map" do
    get :show, :id => theme_maps(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => theme_maps(:one).to_param
    assert_response :success
  end

  test "should update theme_map" do
    put :update, :id => theme_maps(:one).to_param, :theme_map => { }
    assert_redirected_to theme_map_path(assigns(:theme_map))
  end

  test "should destroy theme_map" do
    assert_difference('ThemeMap.count', -1) do
      delete :destroy, :id => theme_maps(:one).to_param
    end

    assert_redirected_to theme_maps_path
  end
end
