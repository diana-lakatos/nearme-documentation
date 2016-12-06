# frozen_string_literal: true
class UserBlogPostDrop < BaseDrop
  # @return [UserBlogPostDrop]
  attr_reader :blog_post

  # @!method title
  #   @return [String] Post's title
  # @!method previous_blog_post
  #   @return [UserBlogPostDrop] the previously published user blog post
  # @!method next_blog_post
  #   @return [UserBlogPostDrop] the next published user blog post
  # @!method author_biography
  #   @return [String] Post author's biography
  # @!method user
  #   @return [UserDrop] User author of the blog post
  delegate :title, :previous_blog_post, :next_blog_post, :author_biography, :user, to: :blog_post

  def initialize(blog_post)
    @blog_post = blog_post
  end

  # @todo -- heavy copy paste warning -- my comments are in blog_post_drop.rb. Dont want to repeat myself

  # @return [String] post's content
  def content
    @blog_post.content.to_s.html_safe
  end

  # @return [String] post's excerpt
  def excerpt
    @blog_post.excerpt.to_s.html_safe
  end

  # @return [String] post author's name; taken from the user object if not present
  #   for the user blog post object
  def author_name
    @blog_post.decorate.author_name
  end

  # @return [Boolean] whether the author has an avatar or name to display
  def show_author?
    @blog_post.author_avatar.present? || @blog_post.author_name.present?
  end

  # @return [Boolean] whether the author's avatar is present
  def show_author_avatar?
    @blog_post.author_avatar.present?
  end

  # @return [String] url for the hero image
  def hero_image_url
    @blog_post.hero_image.url
  end

  # @return [String] url for the hero image 'medium'-sized
  def medium_hero_image_url
    @blog_post.hero_image.url(:medium)
  end

  # @return [Boolean] whether the hero image is present
  def hero_image_present?
    @blog_post.hero_image.present?
  end

  # @return [String] path to the user's profile path
  def user_path
    routes.user_path(@blog_post.user)
  end

  # @return [String] full url for post page
  def post_url
    urlify(routes.user_blog_post_show_path(user_id: @blog_post.user_id, id: @blog_post))
  end

  # @return [String] path for post page
  def post_path
    routes.user_blog_post_show_path(user_id: @blog_post.user_id, id: @blog_post)
  end

  # @return [String] path for post published before current post
  def previous_post_path
    routes.user_blog_post_show_path(user_id: @blog_post.user_id, id: @blog_post.previous_blog_post)
  end

  # @return [String] path for post published after current post
  def next_post_path
    routes.user_blog_post_show_path(user_id: @blog_post.user_id, id: @blog_post.next_blog_post)
  end

  # @return [String] url for author's avatar image
  def author_avatar_url(style = :medium)
    @blog_post.author_avatar.url(style)
  end

  # @return [String] formatted representation of the date when the user blog post was published
  def published_at
    @blog_post.decorate.published_at
  end
end
