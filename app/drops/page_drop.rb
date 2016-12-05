# frozen_string_literal: true
class PageDrop < BaseDrop
  # @return [PageDrop]
  attr_reader :page

  # @!method id
  #   @return [Integer] numeric identifier for the page
  # @!method slug
  #   @return [String] User & SEO friendly short text used in the URL
  # @!method updated_at
  #   Last time when the page was updated
  #   @return [DateTime]
  delegate :slug, :updated_at, :id, to: :page

  def initialize(page)
    @page = page
  end

  # @return [String] title of the page
  def title
    @page.path
  end

  # @return [String] url of the page
  def page_url
    @page.redirect? ? @page.redirect_url : routes.pages_path(@page)
  end

  # @return [String] "_blank" if the page is a redirect and is supposed to be opened in a new window
  #   otherwise returns an empty string
  # @todo -- is there any reason why this is in page drop?
  def open_in_target
    @page.redirect? && @page.open_in_new_window? ? '_blank' : ''
  end

  # @return [String] "nofollow" if the page is a redirect and is not a redirect to any of the
  #   domains associated with the page; otherwise returns an empty string
  # @todo -- is there any reason why this is in page drop?
  def link_rel
    @page.redirect? && !@page.redirect_url_in_known_domain? ? 'nofollow' : ''
  end
end
