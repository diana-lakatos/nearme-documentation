class BlogPostDrop < BaseDrop

  attr_reader :blog_post

  # title
  #   Post's title
  # previous_blog_post
  #   object representing a post published before current post
  # next_blog_post
  #   object representing a post published after current post
  # author_biography
  #   post author's biography
  delegate :title, :previous_blog_post, :next_blog_post, :author_biography, :user, to: :blog_post

  def initialize(blog_post)
    @blog_post = blog_post
  end

  # post's content
  def content
    @blog_post.content.to_s.html_safe
  end

  # post's excerpt
  def excerpt
    @blog_post.decorate.blog_post_excerpt
  end

  # post author's name
  def author_name
    @blog_post.author_name
  end

  # chceck if author's name is present
  def author_name_present?
    @blog_post.author_name.present?
  end

  # check if author has an avatar or name to display
  def show_author?
    @blog_post.author_avatar.present? || @blog_post.author_name.present?
  end

  # check if author's avatar can be displayed
  def show_author_avatar?
    @blog_post.author_avatar.present? || @blog_post.author_name.present?
  end

  # check if author avatar is present
  def author_avatar_present?
    @blog_post.author_avatar.present?
  end

  # url for user's profile path
  def user_path
    routes.user_path(@blog_post.user)
  end

  # full url for post page
  def post_url
    routes.blog_post_url(@blog_post, host: platform_context_decorator.instance.default_domain.name)
  end

  # path for post page
  def post_path
    routes.blog_post_path(@blog_post)
  end

  # returns date when post was published or created
  def published_at
    @blog_post.published_at.presence || @blog_post.created_at
  end

  # path for post published before current post
  def previous_post_path
    routes.blog_post_path(@blog_post.previous_blog_post)
  end

  # path for post published after current post
  def next_post_path
    routes.blog_post_path(@blog_post.next_blog_post)
  end

  # url for author's avatar thumb image
  def author_avatar_thumb_url
    @blog_post.author_avatar.url(:thumb)
  end

  # url for author's avatar medium image
  def author_avatar_medium_url
    @blog_post.author_avatar.url(:medium)
  end

  # check if header image is present
  def header_present?
    @blog_post.header.present?
  end

  # url for header image
  def header_url
    @blog_post.header.present? ? @blog_post.header.url : nil
  end

  def link_for_enquirer
    @blog_post.user.seller_profile ? '' : routes.user_path(@blog_post.user)
  end

end
