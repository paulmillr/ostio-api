class PostsController < ApplicationController
  before_filter :check_sign_in, except: [:index, :show]
  before_filter :check_permissions, except: [:index, :create, :show]

  before_filter do
    @user = User.find_by_login!(params[:user_id])
    @repo = @user.repos.find_by_name!(params[:repo_id])
    @topic = @repo.topics.find_by_number!(params[:topic_id])
  end

  def check_permissions
    not_authorized unless current_user == @user or current_user == @post.user
  end

  # GET /posts
  # GET /posts.json
  def index
    @posts = @topic.posts
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(params[:post].merge({user: current_user}))

    if @post.save
      render json: @post, status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    @post = Post.find(params[:id])

    if @post.update_attributes(params[:post])
      head :no_content
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    head :no_content
  end
end
