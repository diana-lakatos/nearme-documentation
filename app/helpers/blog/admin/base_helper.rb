module Blog::Admin::BaseHelper
  def blog_admin_nav_item(text, path, controller)
    container_class = 'active' if params[:controller] == "blog/admin/#{controller}"
    content_tag(:li, class: container_class) do
      link_to text, path
    end
  end
end
