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
      @user_repos = @user.repos.all
      @user_repos_ids = @user_repos.map(&:github_id)
      @github_repos = Octokit.repos(@user.login)
      @github_repos_ids = @github_repos.map { |repo| repo[:id].to_i }
      @github_repos_assoc = {}
      @github_repos.each do |repo|
        @github_repos_assoc[repo[:id].to_i] = repo
      end
      remove_old_user_repos
      add_new_user_repos
      puts 'Done!'
      render json: @user_repos
    end

    private

    def create_new_repo(github_repo)
      user_repo = Repo.new
      user_repo.assign_attributes({
        user: @user,
        name: github_repo[:name],
        github_id: github_repo[:id]
      }, without_protection: true)
      user_repo.save!
      user_repo
    end

    def add_new_user_repos
      (@github_repos_ids - @user_repos_ids).each do |github_repo|
        @user_repos << create_new_repo(@github_repos_assoc[github_repo])
      end
    end

    def remove_old_user_repos
      Repo.destroy_all(github_id: (@user_repos_ids - @github_repos_ids))
    end
  end
end