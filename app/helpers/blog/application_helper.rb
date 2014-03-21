module Blog::ApplicationHelper

  def blog_title(page_title)
    content_for :title, page_title
  end

  def blog_title_tag
    content_for?(:title) ? content_for(:title) + " | " + @blog_instance.name : @blog_instance.name
  end
end
