class ApplicationController < ActionController::Base
  protect_from_forgery

  def check_sign_in
    unless user_signed_in?
      render status: 401, json: {error: 'Not authorized'}
    end
  end
end
