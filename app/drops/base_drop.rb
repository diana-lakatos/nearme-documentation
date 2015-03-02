class BaseDrop < Liquid::Drop

  def formatted_date
    
  end

  private

  def routes
    Rails.application.routes.url_helpers
  end

  def image_url(source)
    URI.join(routes.root_url, 'assets/', source)
  end

  def urlify(path)
    'http://' + platform_context_decorator.host + path
  end

  def platform_context_decorator
    @platform_context_decorator ||= PlatformContext.current.decorate
  end
end
