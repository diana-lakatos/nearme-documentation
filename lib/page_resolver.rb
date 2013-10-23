class PageResolver < ActionView::FileSystemResolver

  def find_templates(name, prefix, partial, details)
    return [] unless details[:page_path]
    @page = details[:theme].first.pages.find_by_path(details[:page_path].first)

    # Display default page
    if !@page && Theme::DEFAULT_THEME_PAGES.include?(details[:page_path].first)
      super(details[:page_path].first, prefix, partial, details)
    else
      super
    end
  end

  # We are not using standard ruby Singleton because constructor of ActionView::FileSystemResolver needs initialization arguments 
  @@instance = PageResolver.new('app/views')
 
  def self.instance
    return @@instance
  end

  private_class_method :new
end
