class OmniauthCallbacksController < ApplicationController
  def github
    omniauth = request.env['omniauth.auth']

    unless omniauth
      return render status: 500, json: {error: 'Error while authenticating via GitHub'}
    end

    info = omniauth['extra']['raw_info']
    params = {
      github_id: info['id'],
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
      existing_user = User.find_by_github_id(params[:github_id])
      if existing_user
        # Sign in.
        existing_user.login = params[:login]
        existing_user.email = params[:email]
        existing_user.name = params[:name]
        existing_user.gravatar_id = params[:gravatar_id]
        existing_user.save!
        render json: {authentication_token: existing_user.authentication_token}
      else
        # Sign up.
        user = User.new(params)
        user.save!
        render json: {authentication_token: user.authentication_token}
      end
    end
  end
end
