class BreadcrumbsList
  include ActionView::Helpers::UrlHelper

  def initialize(*breadcrumbs_list)
    @breadcrumbs_list = breadcrumbs_list
  end

  def append_location(title, url = nil)
    @breadcrumbs_list << { title: title, url: url }
  end

  def to_s
    breadcrumbs = []

    @breadcrumbs_list.each_with_index do |list_item, index|
      if list_item[:url] && index < @breadcrumbs_list.length - 1
        breadcrumbs << link_to(list_item[:title], list_item[:url])
      else
        breadcrumbs << list_item[:title]
      end
    end

    breadcrumbs.join(' > ').html_safe
  end
end
