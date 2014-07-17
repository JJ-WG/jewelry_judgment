require 'test_helper'

class Historic::HistoricDataControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
