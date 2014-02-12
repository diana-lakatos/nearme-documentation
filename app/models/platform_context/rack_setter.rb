# Module responsible for setting correct PlatformContext.current based on current domain.
# If current domain is invalid, we redirect to our landing page.
#
# Usage:
#
# just ensure it's added to config/application.rb as a rack middleware.

class PlatformContext::RackSetter
  def initialize(app)
    @app = app
  end

  def call(env)
    ::PlatformContext.clear_current
    request = ActionDispatch::Request.new(env)
    ::PlatformContext.current = ::PlatformContext.new(request.host)
    if ::PlatformContext.current.valid_domain?
      Rails.logger.info "platform_context: #{::PlatformContext.current.to_h}"
      I18n.backend.backends.first.instance_id = ::PlatformContext.current.instance.id
      @app.call(env)
    else
      [302, {"Location" => 'http://near-me.com/?domain_not_valid=true'}, self]
    end
  end

  def each(&block)
  end

end
