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
      not_authorized unless current_user == @user or current_user == @topic.user
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

    # POST /topics
    # POST /topics.json
    def create
      @topic = Topic.new(params[:topic])
      @topic.assign_attributes(
        {user: current_user, repo: @repo}, without_protection: true
      )

      if @topic.save
        render json: @topic, status: :created, location: v1_user_repo_topic_path(@user, @repo, @topic)
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
