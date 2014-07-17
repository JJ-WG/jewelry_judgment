require 'test_helper'

class ExpenseTypesControllerTest < ActionController::TestCase
  setup do
    @expense_type = expense_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:expense_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create expense_type" do
    assert_difference('ExpenseType.count') do
      post :create, expense_type: { expense_index: @expense_type.expense_index, name: @expense_type.name, tax_division_id: @expense_type.tax_division_id, view_order: @expense_type.view_order }
    end

    assert_redirected_to expense_type_path(assigns(:expense_type))
  end

  test "should show expense_type" do
    get :show, id: @expense_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @expense_type
    assert_response :success
  end

  test "should update expense_type" do
    put :update, id: @expense_type, expense_type: { expense_index: @expense_type.expense_index, name: @expense_type.name, tax_division_id: @expense_type.tax_division_id, view_order: @expense_type.view_order }
    assert_redirected_to expense_type_path(assigns(:expense_type))
  end

  test "should destroy expense_type" do
    assert_difference('ExpenseType.count', -1) do
      delete :destroy, id: @expense_type
    end

    assert_redirected_to expense_types_path
  end
end
