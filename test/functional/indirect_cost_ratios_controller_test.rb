require 'test_helper'

class IndirectCostRatiosControllerTest < ActionController::TestCase
  setup do
    @indirect_cost_ratio = indirect_cost_ratios(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:indirect_cost_ratios)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create indirect_cost_ratio" do
    assert_difference('IndirectCostRatio.count') do
      post :create, indirect_cost_ratio: { division: @indirect_cost_ratio.division, order_form: @indirect_cost_ratio.order_form, ratio: @indirect_cost_ratio.ratio }
    end

    assert_redirected_to indirect_cost_ratio_path(assigns(:indirect_cost_ratio))
  end

  test "should show indirect_cost_ratio" do
    get :show, id: @indirect_cost_ratio
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @indirect_cost_ratio
    assert_response :success
  end

  test "should update indirect_cost_ratio" do
    put :update, id: @indirect_cost_ratio, indirect_cost_ratio: { division: @indirect_cost_ratio.division, order_form: @indirect_cost_ratio.order_form, ratio: @indirect_cost_ratio.ratio }
    assert_redirected_to indirect_cost_ratio_path(assigns(:indirect_cost_ratio))
  end

  test "should destroy indirect_cost_ratio" do
    assert_difference('IndirectCostRatio.count', -1) do
      delete :destroy, id: @indirect_cost_ratio
    end

    assert_redirected_to indirect_cost_ratios_path
  end
end
