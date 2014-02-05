class PageDrop < BaseDrop

  def initialize(page)
    @page = page
  end

  def title
    @page.path
  end

  def page_url
    @page.redirect? ? @page.redirect_url : routes.pages_path(@page)
  end

  def open_in_target
    (@page.redirect? && @page.open_in_new_window?) ? '_blank' : ''
  end

  def link_rel
    @page.redirect? && !@page.redirect_url_in_known_domain? ? 'nofollow' : ''
  end
end
