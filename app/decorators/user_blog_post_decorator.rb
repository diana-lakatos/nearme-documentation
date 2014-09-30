class UserBlogPostDecorator < UserBlogDecorator
  include Draper::LazyHelpers

  delegate_all

  def title_link
    link_to object.title, user_blog_post_show_path(object.user.id, object), target: '_blank'
  end

  def author_and_date
    "#{link_to object.author_name, '#'} wrote this on #{published_at}".html_safe
  end

  def published_at
    l object.published_at, format: :short
  end

  def created_at
    l object.created_at, format: :only_date
  end
end
