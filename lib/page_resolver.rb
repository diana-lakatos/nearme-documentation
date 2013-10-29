require 'singleton'

class PageResolver < ActionView::FileSystemResolver
  include Singleton

  def initialize
    super('app/views')
  end

  def find_templates(name, prefix, partial, details)
    return [] unless details[:page_path]
    @page = details[:platform_context].first.theme.pages.find_by_slug(details[:page_path].first)

    # Display default page
    if !@page && Theme::DEFAULT_THEME_PAGES.include?(details[:page_path].first)
      super(details[:page_path].first, prefix, partial, details)
    else
      super
    end
  end
end
