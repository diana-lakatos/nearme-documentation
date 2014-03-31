class BlogPostDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def blog_post_excerpt
    excerpt.presence || truncate(strip_tags(content), length: 200) 
  end

end
