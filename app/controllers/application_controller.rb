class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  def check_sign_in
    not_authorized unless user_signed_in?
  end

  def check_permissions
    unless current_user.is_admin?
      if @user.type == 'User'
        not_authorized unless current_user == @user
      else
        not_authorized unless @user.owners.include?(current_user)
      end
    end
  end

  def not_authorized
    render status: 401, json: {error: 'Not authorized'}
  end
end
