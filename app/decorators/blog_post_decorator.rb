class BlogPostDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def blog_post_excerpt
    strip_tags(excerpt.to_s).present? ? excerpt : truncate(strip_tags(content), length: 200, escape: false)
  end
end
