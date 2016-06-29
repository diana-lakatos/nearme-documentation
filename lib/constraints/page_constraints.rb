class Constraints::PageConstraints
  def matches?(request)
    params = request.path_parameters
    Page.where(slug: Page.possible_slugs([params[:slug], params[:slug2], params[:slug3]].compact.join('/'), params[:format])).exists? ||
      Page.where(slug: Page.possible_slugs([params[:slug], params[:slug2]].compact.join('/'), params[:format])).exists? ||
      Page.where(slug: Page.possible_slugs(params[:slug], params[:format])).exists?
  end
end
