class PageResolver < ActionView::FileSystemResolver

  attr_accessor :theme
  attr_accessor :page_path

  def initialize(path, pattern = nil, theme = nil, page_path = nil)
    super(path, pattern)
    @theme = theme
    @page_path = page_path
  end


  def find_templates(name, prefix, partial, details)
    @page = theme.pages.find_by_path(@page_path)

    # Display default page
    if !@page && Theme::DEFAULT_THEME_PAGES.include?(@page_path)
      super(@page_path, prefix, partial, details)
    else
      super
    end
  end
end
