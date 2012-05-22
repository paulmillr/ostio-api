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

  # POST /repos
  # POST /repos.json
  def create
    @repo = Repo.new(params[:repo])
    @repo.assign_attributes({user: current_user}, without_protection: true)

    if @repo.save
      render json: @repo, status: :created, location: user_repo_path(@user, @repo)
    else
      render json: @repo.errors, status: :unprocessable_entity
    end
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

  # DELETE /repos/1
  # DELETE /repos/1.json
  def destroy
    @repo = @user.repos.find_by_name!(params[:id])
    @repo.destroy

    head :no_content
  end
end
