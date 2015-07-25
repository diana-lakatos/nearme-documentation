class BaseDrop < Liquid::Drop

  private

  def routes
    Rails.application.routes.url_helpers
  end

  def asset_url(source)
    ActionController::Base.helpers.asset_url(source)
  end

  alias_method :image_url, :asset_url

  def urlify(path)
    'http://' + platform_context_decorator.host + path
  end

  def platform_context_decorator
    @platform_context_decorator ||= PlatformContext.current.decorate
  end
end
