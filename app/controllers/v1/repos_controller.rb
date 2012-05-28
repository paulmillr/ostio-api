module V1
  class ReposController < ApplicationController
    before_filter :check_sign_in, except: [:index, :show]
    before_filter :load_parents
    before_filter :check_permissions, except: [:index, :show]

    def load_parents
      @user = User.find_by_login!(params[:user_id])
    end

    def check_permissions
      not_authorized unless current_user == @user
    end

    # GET /repos
    # GET /repos.json
    def index
      @repos = @user.repos
    end

    # GET /repos/1
    # GET /repos/1.json
    def show
      @repo = @user.repos.find_by_name!(params[:id])
    end

    # PATCH/PUT /repos/1
    # PATCH/PUT /repos/1.json
    def update
      @repo = @user.repos.find_by_name!(params[:id])

      if @repo.update_attributes(params[:repo])
        head :no_content
      else
        render json: @repo.errors, status: :unprocessable_entity
      end
    end
  end
end