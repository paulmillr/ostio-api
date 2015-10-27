require 'octokit'

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    omniauth = request.env['omniauth.auth']

    unless omniauth
      return render status: 500, json: {error: 'Error while authenticating via GitHub'}
    end

    info = omniauth['extra']['raw_info']
    # p [1234, info[:name]]
    params = {
      github_id: info[:id].to_i,
      github_token: omniauth[:credentials][:token],
      login: info[:login],
      email: info[:email],
      name: info[:name],
      gravatar_id: info[:gravatar_id],
      type: info[:type]
    }

    unless params[:github_id] and params[:login]
      return render status: 500, json: {error: 'GitHub returned invalid data for the user id'}
    end

    if user_signed_in?
      redirect_to controller: 'users', action: 'show_current'
    else
      @user = User.find_by_github_id(params[:github_id]) || User.new
      refresh_attributes_and_save_user(params)
    end
  end

  private

  def create_new_organization(params)
    organization = User.new
    # Org doesn't exist, add it.
    organization.assign_attributes({
      github_id: params[:id],
      login: params[:login],
      gravatar_id: params[:gravatar_id],
      name: params[:login],
      type: 'Organization'
    }, without_protection: true)
    organization.save!
    organization
  end

  def add_new_user_orgs
    orgs = (@github_orgs.keys - @user_orgs.keys)
    # p [2345, orgs]
    orgs.each do |github_org_id|
      github_org = @github_orgs[github_org_id]
      org = User.find_by_github_id(github_org_id) || create_new_organization(github_org)
      # p [1111, github_org, org]
      @user.organizations << org
    end
  end

  def remove_old_user_orgs
    list = @user_orgs.keys - @github_orgs.keys
    p [688, list]
    User.destroy_all(github_id: list)
  end

  def sync_user_orgs
    @github_orgs = {}
    Octokit.orgs(@user.login).each do |github_org|
      @github_orgs[github_org[:id].to_i] = github_org
    end

    @user_orgs = {}
    @user.organizations.each do |user_org|
      @user_orgs[user_org.github_id] = user_org
    end

    # remove_old_user_orgs()
    # add_new_user_orgs()
  end

  def refresh_attributes_and_save_user(params)
    @user.assign_attributes(params, without_protection: true)
    @user.save!
    sync_user_orgs
    query = {
      login: @user.login, accessToken: @user.authentication_token
    }.to_query
    domain = request.env['omniauth.origin']
    sep = if domain.include?('?') then '&' else '?' end
    redirect_to domain + sep + query
  end
end
