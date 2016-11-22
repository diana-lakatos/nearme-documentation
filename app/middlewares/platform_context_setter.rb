# frozen_string_literal: true
# Module responsible for setting correct PlatformContext.current based on current domain.
# If current domain is invalid, we redirect to our landing page.
#
# Usage:
#
# just ensure it's added to config/application.rb as a rack middleware.

class PlatformContextSetter
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) if env['PATH_INFO'] =~ /^\/assets\//
    return [200, {}, ['pong']] if env['PATH_INFO'] == '/ping'

    ::PlatformContext.clear_current
    request = ActionDispatch::Request.new(env)
    platform_context = ::PlatformContext.new(request.host)
    if !platform_context.should_redirect?
      ::PlatformContext.current = platform_context
      I18n.backend.backends.first.instance_id = ::PlatformContext.current.instance.try(:id) if I18n.backend.respond_to?(:backends)
      @app.call(env)
    else
      [
        platform_context.redirect_code,
        { 'Location' => platform_context.redirect_url(request.path_info) },
        self
      ]
    end
  end

  def each(&_block)
  end
end
