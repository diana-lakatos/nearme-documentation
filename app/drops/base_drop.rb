class BaseDrop < Liquid::Drop
  private
  def routes
    Rails.application.routes.url_helpers
  end

  def image_url(source)
    URI.join(routes.root_url, 'assets/', source)
  end
end
