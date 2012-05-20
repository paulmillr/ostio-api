class TopicsController < ApplicationController
  before_filter do
    @user = User.find_by_login!(params[:user_id])
    @repo = @user.repos.find_by_name!(params[:repo_id])
  end

  # GET /topics
  # GET /topics.json
  def index
    @topics = @repo.topics
  end

  # GET /topics/1
  # GET /topics/1.json
  def show
    @topic = @repo.topics.find_by_number!(params[:id])
  end

  # GET /topics/new
  # GET /topics/new.json
  def new
    @topic = Topic.new

    render json: @topic
  end

  # POST /topics
  # POST /topics.json
  def create
    @topic = Topic.new(params[:topic])

    if @topic.save
      render json: @topic, status: :created, location: @topic
    else
      render json: @topic.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /topics/1
  # PATCH/PUT /topics/1.json
  def update
    @topic = @repo.topics.find_by_number!(params[:id])

    if @topic.update_attributes(params[:topic])
      head :no_content
    else
      render json: @topic.errors, status: :unprocessable_entity
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.json
  def destroy
    @topic = @repo.topics.find_by_number!(params[:id])
    @topic.destroy

    head :no_content
  end
end
