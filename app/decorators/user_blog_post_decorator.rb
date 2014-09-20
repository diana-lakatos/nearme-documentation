class UserBlogPostDecorator < UserBlogDecorator
  include Draper::LazyHelpers

  delegate_all

  def title_link
    link_to object.title, user_blog_post_path(object), target: '_blank'
  end

  def published_at
    l object.published_at, format: :short
  end

  def created_at
    l object.created_at, format: :only_date
  end
end
