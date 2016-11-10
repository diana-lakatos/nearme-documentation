# frozen_string_literal: true
class UserBlogPostDrop < BaseDrop
  attr_reader :blog_post

  # title
  #   Post's title
  # previous_blog_post
  #   object representing a post published before current post
  # next_blog_post
  #   object representing a post published after current post
  # author_biography
  #   post author's biography
  # published_at
  #   date when post was published
  delegate :title, :previous_blog_post, :next_blog_post, :author_biography, :published_at, :user, to: :blog_post

  def initialize(blog_post)
    @blog_post = blog_post
  end

  # post's content
  def content
    @blog_post.content.to_s.html_safe
  end

  # post's excerpt
  def excerpt
    @blog_post.excerpt.to_s.html_safe
  end

  # post author's name
  def author_name
    @blog_post.decorate.author_name
  end

  # check if author has an avatar or name to display
  def show_author?
    @blog_post.author_avatar.present? || @blog_post.author_name.present?
  end

  # check if author's avatar can be displayed
  def show_author_avatar?
    @blog_post.author_avatar.present?
  end

  # url for hero image
  def hero_image_url
    @blog_post.hero_image.url
  end

  def medium_hero_image_url
    @blog_post.hero_image.url(:medium)
  end

  # check if hero image is present
  def hero_image_present?
    @blog_post.hero_image.present?
  end

  # url for user's profile path
  def user_path
    routes.user_path(@blog_post.user)
  end

  # full url for post page
  def post_url
    urlify(routes.user_blog_post_show_path(user_id: @blog_post.user_id, id: @blog_post))
  end

  # path for post page
  def post_path
    routes.user_blog_post_show_path(user_id: @blog_post.user_id, id: @blog_post)
  end

  # path for post published before current post
  def previous_post_path
    routes.user_blog_post_show_path(user_id: @blog_post.user_id, id: @blog_post.previous_blog_post)
  end

  # path for post published after current post
  def next_post_path
    routes.user_blog_post_show_path(user_id: @blog_post.user_id, id: @blog_post.next_blog_post)
  end

  # url for author's avatar image
  def author_avatar_url(style = :medium)
    @blog_post.author_avatar.url(style)
  end

  def published_at
    @blog_post.decorate.published_at
  end
end
