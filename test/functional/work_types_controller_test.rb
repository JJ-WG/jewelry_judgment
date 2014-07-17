require 'test_helper'

class WorkTypesControllerTest < ActionController::TestCase
  setup do
    @work_type = work_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:work_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create work_type" do
    assert_difference('WorkType.count') do
      post :create, work_type: { name: @work_type.name, view_order: @work_type.view_order }
    end

    assert_redirected_to work_type_path(assigns(:work_type))
  end

  test "should show work_type" do
    get :show, id: @work_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @work_type
    assert_response :success
  end

  test "should update work_type" do
    put :update, id: @work_type, work_type: { name: @work_type.name, view_order: @work_type.view_order }
    assert_redirected_to work_type_path(assigns(:work_type))
  end

  test "should destroy work_type" do
    assert_difference('WorkType.count', -1) do
      delete :destroy, id: @work_type
    end

    assert_redirected_to work_types_path
  end
end
