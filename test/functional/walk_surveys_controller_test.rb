require 'test_helper'

class WalkSurveysControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:walk_surveys)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create walk_survey" do
    assert_difference('WalkSurvey.count') do
      post :create, :walk_survey => { }
    end

    assert_redirected_to walk_survey_path(assigns(:walk_survey))
  end

  test "should show walk_survey" do
    get :show, :id => walk_surveys(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => walk_surveys(:one).to_param
    assert_response :success
  end

  test "should update walk_survey" do
    put :update, :id => walk_surveys(:one).to_param, :walk_survey => { }
    assert_redirected_to walk_survey_path(assigns(:walk_survey))
  end

  test "should destroy walk_survey" do
    assert_difference('WalkSurvey.count', -1) do
      delete :destroy, :id => walk_surveys(:one).to_param
    end

    assert_redirected_to walk_surveys_path
  end
end
