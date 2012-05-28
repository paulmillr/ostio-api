require 'octokit'

module V1
  class SyncReposController < ApplicationController
    before_filter :check_sign_in
    before_filter :load_parents
    before_filter :check_permissions

    def load_parents
      @user = User.find_by_login!(params[:user_id])
    end

    def check_permissions
      if @user.type == 'User'
        not_authorized unless current_user == @user
      else
        not_authorized unless @user.owners.include?(current_user)
      end
    end

    # POST /sync_repos
    def create
      @github_repos = {}
      Octokit.repos(@user.login).each do |github_repo|
        @github_repos[github_repo[:id].to_i] = github_repo
      end

      @user_repos = {}
      @user.repos.each do |user_repo|
        @user_repos[user_repo.github_id] = user_repo
      end

      remove_old_user_repos
      add_new_user_repos
      render json: @user.repos
    end

    private

    def create_new_repo(github_repo)
      user_repo = Repo.new
      user_repo.assign_attributes({
        user: @user,
        name: github_repo[:name],
        github_id: github_repo[:id], 
      }, without_protection: true)
      user_repo.save!
      user_repo
    end

    def add_new_user_repos
      (@github_repos.keys - @user_repos.keys).each do |github_repo_id|
        @user.repos << create_new_repo(@github_repos[github_repo_id])
      end
    end

    def remove_old_user_repos
      Repo.destroy_all(github_id: @user_repos.keys - @github_repos.keys)
    end
  end
end