class BadRequestCatcher
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue ActionController::BadRequest
    ::Rails.logger.warn("WARN: 400 ActionController::BadRequest: #{env['REQUEST_URI']}")
    [
      400, { 'Content-Type' => 'text/html' },
      ['BadRequest']
    ]
  end
end
