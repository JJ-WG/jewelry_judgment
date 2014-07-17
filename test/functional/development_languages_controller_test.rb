require 'test_helper'

class DevelopmentLanguagesControllerTest < ActionController::TestCase
  setup do
    @development_language = development_languages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:development_languages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create development_language" do
    assert_difference('DevelopmentLanguage.count') do
      post :create, development_language: { name: @development_language.name, view_order: @development_language.view_order }
    end

    assert_redirected_to development_language_path(assigns(:development_language))
  end

  test "should show development_language" do
    get :show, id: @development_language
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @development_language
    assert_response :success
  end

  test "should update development_language" do
    put :update, id: @development_language, development_language: { name: @development_language.name, view_order: @development_language.view_order }
    assert_redirected_to development_language_path(assigns(:development_language))
  end

  test "should destroy development_language" do
    assert_difference('DevelopmentLanguage.count', -1) do
      delete :destroy, id: @development_language
    end

    assert_redirected_to development_languages_path
  end
end
