require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = user(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { authority_id: @user.authority_id, crypted_password: @user.crypted_password, current_login_at: @user.current_login_at, deleted_at: @user.deleted_at, last_login_at: @user.last_login_at, login: @user.login, login_count: @user.login_count, name: @user.name, name_ruby: @user.name_ruby, password_salt: @user.password_salt, persistence_token: @user.persistence_token, section_id: @user.section_id, unit_price_id: @user.unit_price_id }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user, user: { authority_id: @user.authority_id, crypted_password: @user.crypted_password, current_login_at: @user.current_login_at, deleted_at: @user.deleted_at, last_login_at: @user.last_login_at, login: @user.login, login_count: @user.login_count, name: @user.name, name_ruby: @user.name_ruby, password_salt: @user.password_salt, persistence_token: @user.persistence_token, section_id: @user.section_id, unit_price_id: @user.unit_price_id }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
