require 'test_helper'

class NeighborSurveysControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:neighbor_surveys)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create neighbor_survey" do
    assert_difference('NeighborSurvey.count') do
      post :create, :neighbor_survey => { }
    end

    assert_redirected_to neighbor_survey_path(assigns(:neighbor_survey))
  end

  test "should show neighbor_survey" do
    get :show, :id => neighbor_surveys(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => neighbor_surveys(:one).to_param
    assert_response :success
  end

  test "should update neighbor_survey" do
    put :update, :id => neighbor_surveys(:one).to_param, :neighbor_survey => { }
    assert_redirected_to neighbor_survey_path(assigns(:neighbor_survey))
  end

  test "should destroy neighbor_survey" do
    assert_difference('NeighborSurvey.count', -1) do
      delete :destroy, :id => neighbor_surveys(:one).to_param
    end

    assert_redirected_to neighbor_surveys_path
  end
end
