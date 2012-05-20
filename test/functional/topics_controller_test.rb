require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  setup do
    @topic = topics(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:topics)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create topic" do
    assert_difference('Topic.count') do
      post :create, topic: { created_at: @topic.created_at, number: @topic.number, repo_id: @topic.repo_id, title: @topic.title, updated_at: @topic.updated_at }
    end

    assert_response 201
  end

  test "should show topic" do
    get :show, id: @topic
    assert_response :success
  end

  test "should update topic" do
    put :update, id: @topic, topic: { created_at: @topic.created_at, number: @topic.number, repo_id: @topic.repo_id, title: @topic.title, updated_at: @topic.updated_at }
    assert_response 204
  end

  test "should destroy topic" do
    assert_difference('Topic.count', -1) do
      delete :destroy, id: @topic
    end

    assert_response 204
  end
end
