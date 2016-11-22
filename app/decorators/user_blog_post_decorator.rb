# frozen_string_literal: true
class UserBlogPostDecorator < UserBlogDecorator
  include Draper::LazyHelpers

  delegate_all

  def title_link
    link_to object.title, user_blog_post_show_path(object.user.id, object), target: '_blank'
  end

  def url_to
    user_blog_post_show_path(object.user.id, object)
  end

  # @return [String] post author's name; taken from the user object if not present
  #   for the user blog post object
  def author_name
    object.author_name.empty? ? object.user.name : object.author_name
  end

  def author_and_date
    "#{link_to author_name, '#'} wrote this on #{published_at}".html_safe
  end

  # @return [String] formatted representation of the date when the user blog post was published
  def published_at
    l object.published_at.to_date, format: :long if object.published_at
  end

  def published_at_datetime
    l object.published_at.to_date, format: :long if object.published_at
  end

  def created_at
    l object.created_at.to_date, format: :long if object.published_at
  end

  def published_at_frontend
    l object.published_at.to_date, format: :day_and_month if object.published_at
  end

  def blog_post_excerpt
    strip_tags(excerpt.to_s).present? ? excerpt : truncate(strip_tags(content), length: 200, escape: false)
  end
end
