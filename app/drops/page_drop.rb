class PageDrop < BaseDrop

  def initialize(page)
    @page = page
  end

  def title
    @page.path
  end

  def page_url
    routes.pages_path(@page)
  end
end
