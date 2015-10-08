class PageConstraints
  def matches?(request)
    params = request.path_parameters
    Page.where(slug: Page.possible_slugs(params[:slug], params[:format])).exists?
  end
end
