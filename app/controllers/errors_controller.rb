class ErrorsController < ApplicationController
  def not_authorized
    render status: 401, json: {error: 'Not authorized'}
  end

  def not_found
    render status: 404, json: {message: 'Not Found'}
  end

  def i_am_a_teapot
    render status: 418, json: {message: 'I\'m a Teapot'}
  end

  def server_error
    render status: 500, json: {message: 'Server Error'}
  end
end
