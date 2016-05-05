require 'test_helper'

class TrustsControllerTest < ActionController::TestCase
  setup do
    @trust = trusts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trusts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create trust" do
    assert_difference('Trust.count') do
      post :create, trust: { score: @trust.score }
    end

    assert_redirected_to trust_path(assigns(:trust))
  end

  test "should show trust" do
    get :show, id: @trust
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @trust
    assert_response :success
  end

  test "should update trust" do
    patch :update, id: @trust, trust: { score: @trust.score }
    assert_redirected_to trust_path(assigns(:trust))
  end

  test "should destroy trust" do
    assert_difference('Trust.count', -1) do
      delete :destroy, id: @trust
    end

    assert_redirected_to trusts_path
  end
end
