module V1
  class TopicsController < ApplicationController
    before_filter :check_sign_in, except: [:index, :show]
    before_filter :load_parents
    before_filter :check_permissions, except: [:index, :create, :show]

    def load_parents
      @user = User.find_by_login!(params[:user_id])
      @repo = @user.repos.find_by_name!(params[:repo_id])
    end

    def check_permissions
      unless current_user == @topic.user
        if @user.type == 'User'
          not_authorized unless current_user == @user
        else
          not_authorized unless @user.owners.include?(current_user)
        end
      end
    end

    def to_json(thing)
      json = thing.as_json({include: {repo: {include: :user}}})
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
      @topics = @repo.topics.order(:updated_at).reverse_order
      @total_posts = Post.where(topic_id: @topics.map(&:id)).group('topic_id').sum('topic_id')
      
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
end
