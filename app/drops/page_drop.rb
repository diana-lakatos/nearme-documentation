class PageDrop < BaseDrop

  attr_reader :page

  delegate :slug, to: :page

  def initialize(page)
    @page = page
  end

  # title of the page
  def title
    @page.path
  end

  # url of the page
  def page_url
    @page.redirect? ? @page.redirect_url : routes.pages_path(@page)
  end

  # returns "_blank" if the page is a redirect and is supposed to be opened in a new window
  # otherwise returns an empty string
  def open_in_target
    (@page.redirect? && @page.open_in_new_window?) ? '_blank' : ''
  end

  # returns "nofollow" if the page is a redirect and is not a redirect to any of the
  # domains associated with the page; otherwise returns an empty string
  def link_rel
    @page.redirect? && !@page.redirect_url_in_known_domain? ? 'nofollow' : ''
  end
end
