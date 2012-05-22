class CookieDisabler
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    headers.delete 'Set-Cookie'
    [status, headers, body]
  end
end

Rails.application.config.middleware.insert_before ::ActionDispatch::Cookies, ::CookieDisabler
