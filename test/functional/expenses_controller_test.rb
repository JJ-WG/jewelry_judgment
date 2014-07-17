require 'test_helper'

class ExpensesControllerTest < ActionController::TestCase
  setup do
    @expense = expenses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:expenses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create expense" do
    assert_difference('Expense.count') do
      post :create, expense: { adjusted_date: @expense.adjusted_date, amount_paid: @expense.amount_paid, expense_type_id: @expense.expense_type_id, item_name: @expense.item_name, project_id: @expense.project_id, tax_division_id: @expense.tax_division_id, user_id: @expense.user_id }
    end

    assert_redirected_to expense_path(assigns(:expense))
  end

  test "should show expense" do
    get :show, id: @expense
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @expense
    assert_response :success
  end

  test "should update expense" do
    put :update, id: @expense, expense: { adjusted_date: @expense.adjusted_date, amount_paid: @expense.amount_paid, expense_type_id: @expense.expense_type_id, item_name: @expense.item_name, project_id: @expense.project_id, tax_division_id: @expense.tax_division_id, user_id: @expense.user_id }
    assert_redirected_to expense_path(assigns(:expense))
  end

  test "should destroy expense" do
    assert_difference('Expense.count', -1) do
      delete :destroy, id: @expense
    end

    assert_redirected_to expenses_path
  end
end
