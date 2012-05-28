require 'octokit'

class OmniauthCallbacksController < ApplicationController
  def github
    omniauth = request.env['omniauth.auth']

    unless omniauth
      return render status: 500, json: {error: 'Error while authenticating via GitHub'}
    end

    info = omniauth['extra']['raw_info']
    params = {
      github_id: info['id'].to_i,
      github_token: omniauth['credentials']['token'],
      login: info['login'],
      email: info['email'],
      name: info['name'],
      gravatar_id: info['gravatar_id'],
      type: info['type']
    }

    unless params[:github_id] and params[:login]
      return render status: 500, json: {error: 'GitHub returned invalid data for the user id'}
    end

    if user_signed_in?
      redirect_to controller: 'users', action: 'show_current'
    else
      user = User.find_by_github_id(params[:github_id]) || User.new
      refresh_attributes_and_save_user(user, params)
    end
  end

  private

  def create_new_organization(params)
    organization = User.new
    organization.assign_attributes({
      github_id: params[:id],
      login: params[:login],
      gravatar_id: /\/avatar\/(\w+)\?/.match(params[:avatar_url])[1],
      type: 'Organization'
    }, without_protection: true)
    organization.save!
    organization
  end

  def add_new_user_orgs(user, user_orgs, github_orgs)
    github_orgs.each do |org|
      existing_org = User.find_by_github_id(org[:id])
      # Check if organization exists in database.
      if existing_org
        # Organization exists, check if current user owns it.
        unless existing_org.owners.include?(user)
          # User doesn't own it, add it.
          user_orgs << existing_org
        end
      else
        # Organization doesn't exist, create it.
        user_orgs << create_new_organization(org)
      end
    end
  end

  def remove_old_user_orgs(user, user_orgs, github_orgs)
    github_orgs_ids = github_orgs.map { |org| org[:id] }.map(&:to_i)

    user_orgs.all.select do |organization|
      !github_orgs_ids.include?(organization[:github_id])
    end.each do |organization|
      user_orgs.delete(organization)
    end
  end

  def sync_user_orgs(user)
    # Get organizations for GitHub.
    github_orgs = Octokit.orgs(user.login)
    user_orgs = user.organizations
    remove_old_user_orgs(user, user_orgs, github_orgs)
    add_new_user_orgs(user, user_orgs, github_orgs)
  end

  def refresh_attributes_and_save_user(user, params)
    user.assign_attributes(params, without_protection: true)
    user.save!
    sync_user_orgs(user)
    render json: {access_token: user.authentication_token}
  end
end
