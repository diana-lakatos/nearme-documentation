class PageConstraints
  def matches?(request)
    Page.where(slug: request.path_parameters[:path]).exists?
  end
end
