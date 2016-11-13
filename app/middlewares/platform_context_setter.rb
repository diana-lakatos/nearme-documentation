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

      @global_options = {
        preserve_host: true,
        preserve_encoding: true,
        x_forwarded_headers: true,
        matching: :all,
        force_ssl: false
      }
      reverse_proxy_middleware = RackReverseProxy::RoundTrip.new(@app, env, @global_options, platform_context.rack_rules)

      if reverse_proxy_middleware.send(:rule).present?
        path = reverse_proxy_middleware.send(:rule).send(:original_spec)
        rule = platform_context.rules.detect { |r| r.path == path }

        user_id = begin env['rack.session']['warden.user.user.key'].try(:first).try(:first).to_s
                  rescue ''
                  end

        additional_headers = { 'UserId' => user_id }
        additional_headers['UserName'] = User.find(user_id).name if user_id.present?
        reverse_proxy_middleware.custom_headers = JSON.parse(rule.headers).merge(additional_headers)
        reverse_proxy_middleware.call
      else
        if I18n.backend.respond_to?(:backends)
          I18n.backend.backends.first.instance_id = ::PlatformContext.current.instance.try(:id)
        end
        @app.call(env)
      end
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
