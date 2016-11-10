class BlogPostDrop < BaseDrop
  # @return [BlogPostDrop]
  attr_reader :blog_post

  # @!method title
  #   the title of the blog post
  #   @return (see BlogPost#title)
  # @!method previous_blog_post
  #   @return [BlogPostDrop] object representing a post published before current post
  # @!method next_blog_post
  #   @return [BlogPostDrop] object representing a post published after current post
  # @!method author_biography
  #   the author biography
  #   @return (see BlogPost#author_biography)
  # @!method user
  #   @return [UserDrop] creator of the blog post
  delegate :title, :previous_blog_post, :next_blog_post, :author_biography, :user, to: :blog_post

  def initialize(blog_post)
    @blog_post = blog_post
  end

  # post's content
  # @return [String]
  def content
    @blog_post.content.to_s.html_safe
  end

  # post's excerpt
  # @return [String]
  def excerpt
    @blog_post.decorate.blog_post_excerpt
  end

  # post author's name
  # @return [String]
  def author_name
    @blog_post.author_name
  end

  # chceck if author's name is present
  # @return [Boolean]
  def author_name_present?
    @blog_post.author_name.present?
  end

  # check if author has an avatar or name to display
  # @return [Boolean]
  def show_author?
    @blog_post.author_avatar.present? || @blog_post.author_name.present?
  end

  # check if author's avatar can be displayed
  # @return [Boolean]
  def show_author_avatar?
    @blog_post.author_avatar.present? || @blog_post.author_name.present?
  end

  # check if author avatar is present
  # @return [Boolean]
  def author_avatar_present?
    @blog_post.author_avatar.present?
  end

  # url for user's profile path
  # @return [String]
  def user_path
    routes.user_path(@blog_post.user)
  end

  # full url for post page
  # @return [String]
  def post_url
    routes.blog_post_url(@blog_post, host: platform_context_decorator.instance.default_domain.name)
  end

  # path for post page
  # @return [String]
  def post_path
    routes.blog_post_path(@blog_post)
  end

  # returns date when post was published or created
  # @return [ActiveSupport::TimeWithZone]
  def published_at
    @blog_post.published_at.presence || @blog_post.created_at
  end

  # path for post published before current post
  # @return [String]
  def previous_post_path
    routes.blog_post_path(@blog_post.previous_blog_post)
  end

  # path for post published after current post
  # @return [String]
  def next_post_path
    routes.blog_post_path(@blog_post.next_blog_post)
  end

  # url for author's avatar thumb image
  # @return [String]
  def author_avatar_thumb_url
    @blog_post.author_avatar.url(:medium)
  end

  # url for author's avatar medium image
  # @return [String]
  def author_avatar_medium_url
    @blog_post.author_avatar.url(:medium)
  end

  # check if header image is present
  # @return [Boolean]
  def header_present?
    @blog_post.header.present?
  end

  # url for header image
  # @return [String]
  def header_url
    @blog_post.header.present? ? @blog_post.header.url : nil
  end

  # path to the user if the user is an enquirer (has a buyer profile)
  # @return [String]
  def link_for_enquirer
    @blog_post.user.seller_profile ? '' : routes.user_path(@blog_post.user)
  end
end
