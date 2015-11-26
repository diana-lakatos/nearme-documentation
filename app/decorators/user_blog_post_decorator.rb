class UserBlogPostDecorator < UserBlogDecorator
  include Draper::LazyHelpers

  delegate_all

  def title_link
    link_to object.title, user_blog_post_show_path(object.user.id, object), target: '_blank'
  end

  def url_to
    user_blog_post_show_path(object.user.id, object)
  end

  def author_name
    object.author_name.empty? ? object.user.name : object.author_name
  end

  def author_and_date
    "#{link_to author_name, '#'} wrote this on #{published_at}".html_safe
  end

  def published_at
    l object.published_at, format: :only_date
  end

  def published_at_datetime
    l object.published_at, format: '%Y-%m-%d'
  end

  def created_at
    l object.created_at, format: :only_date
  end

  def published_at_frontend
    l object.published_at.presence, format: :day_and_month
  end

  def blog_post_excerpt
    strip_tags(excerpt.to_s).present? ? excerpt : truncate(strip_tags(content), length: 200, escape: false)
  end
end
