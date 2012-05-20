require 'test_helper'

class ReposControllerTest < ActionController::TestCase
  setup do
    @repo = repos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:repos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create repo" do
    assert_difference('Repo.count') do
      post :create, repo: { name: @repo.name, user_id: @repo.user_id }
    end

    assert_response 201
  end

  test "should show repo" do
    get :show, id: @repo
    assert_response :success
  end

  test "should update repo" do
    put :update, id: @repo, repo: { name: @repo.name, user_id: @repo.user_id }
    assert_response 204
  end

  test "should destroy repo" do
    assert_difference('Repo.count', -1) do
      delete :destroy, id: @repo
    end

    assert_response 204
  end
end
