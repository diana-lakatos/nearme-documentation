class LiquidLinkRendererForUserPage < LiquidLinkRenderer
  def url(page)
    # We do not preserve GET params
    # We just add the current page param
    url_params = {}
    add_current_page_param(url_params, page)
    @options[:controller].url_for(url_params)
  end
end
