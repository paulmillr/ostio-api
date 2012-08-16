module V1
  class TopicsController < ApplicationController
    before_filter :check_sign_in, except: [:index, :show]
    before_filter :load_parents
    before_filter :check_permissions, only: [:update, :destroy]

    def load_parents
      @user = User.find_by_login!(params[:user_id])
      @repo = @user.repos.find_by_name!(params[:repo_id])
    end

    def check_permissions
      @topic = @repo.topics.find_by_number!(params[:id])
      if current_user != @topic.user
        super
      end
    end

    def to_json(thing)
      json = thing.as_json({include: {
        repo: {include: :user},
        user: {}
      }})
      if json.is_a?(Array)
        json.each do |topic|
          topic['total_posts'] = @total_posts[topic['id']]
        end
      else
        json['total_posts'] = @total_posts
      end
      json
    end

    # GET /topics
    # GET /topics.json
    def index
      @topics = @repo.topics.includes(:user, :repo)
      @total_posts = Post
        .where(topic_id: @topics.map(&:id))
        .group('topic_id').count('topic_id')
      
      render json: to_json(@topics)
    end

    # GET /topics/1
    # GET /topics/1.json
    def show
      @topic = @repo.topics.find_by_number!(params[:id])
      @total_posts = @topic.posts.count
      render json: to_json(@topic)
    end

    # POST /topics
    # POST /topics.json
    def create
      @topic = Topic.new(params[:topic])
      @topic.assign_attributes(
        {user: current_user, repo: @repo}, without_protection: true
      )

      if @topic.save
        @topic.repo.updated_at = Time.now
        @topic.repo.save!
        @total_posts = 1
        render json: to_json(@topic), status: :created
        # The route is buggy. See rails/rails/issues/6564.
        # location: v1_user_repo_topic_path(@user, @repo, @topic)
      else
        render json: @topic.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /topics/1
    # PATCH/PUT /topics/1.json
    def update
      if @topic.update_attributes(params[:topic])
        head :no_content
      else
        render json: @topic.errors, status: :unprocessable_entity
      end
    end

    # DELETE /topics/1
    # DELETE /topics/1.json
    def destroy
      if @topic.destroy
        head :no_content
      else
        render json: @topic.errors, status: :unprocessable_entity
      end
    end
  end
end
