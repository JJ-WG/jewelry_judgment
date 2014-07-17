require 'test_helper'

class TaxDivisionsControllerTest < ActionController::TestCase
  setup do
    @tax_division = tax_divisions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tax_divisions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tax_division" do
    assert_difference('TaxDivision.count') do
      post :create, tax_division: { name: @tax_division.name, tax_rate: @tax_division.tax_rate, view_order: @tax_division.view_order }
    end

    assert_redirected_to tax_division_path(assigns(:tax_division))
  end

  test "should show tax_division" do
    get :show, id: @tax_division
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tax_division
    assert_response :success
  end

  test "should update tax_division" do
    put :update, id: @tax_division, tax_division: { name: @tax_division.name, tax_rate: @tax_division.tax_rate, view_order: @tax_division.view_order }
    assert_redirected_to tax_division_path(assigns(:tax_division))
  end

  test "should destroy tax_division" do
    assert_difference('TaxDivision.count', -1) do
      delete :destroy, id: @tax_division
    end

    assert_redirected_to tax_divisions_path
  end
end
