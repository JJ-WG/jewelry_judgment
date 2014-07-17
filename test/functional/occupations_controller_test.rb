require 'test_helper'

class OccupationsControllerTest < ActionController::TestCase
  setup do
    @occupation = occupations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:occupations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create occupation" do
    assert_difference('Occupation.count') do
      post :create, occupation: { name: @occupation.name, view_order: @occupation.view_order }
    end

    assert_redirected_to occupation_path(assigns(:occupation))
  end

  test "should show occupation" do
    get :show, id: @occupation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @occupation
    assert_response :success
  end

  test "should update occupation" do
    put :update, id: @occupation, occupation: { name: @occupation.name, view_order: @occupation.view_order }
    assert_redirected_to occupation_path(assigns(:occupation))
  end

  test "should destroy occupation" do
    assert_difference('Occupation.count', -1) do
      delete :destroy, id: @occupation
    end

    assert_redirected_to occupations_path
  end
end
