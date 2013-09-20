class BaseDrop < Liquid::Drop
  private
  def routes
    Rails.application.routes.url_helpers
  end
end
