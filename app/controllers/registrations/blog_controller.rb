class Registrations::BlogController < ApplicationController
  before_filter :check_blog_enabled
  before_filter :set_theme

  def index
    @user = blog_user
    @blog_posts = get_blog_posts
    @tags = blog_user.published_blogs.map(&:tags).sort_by(&:name)

    @no_footer = true
    @render_content_outside_container = true
    @blog_rss_feed_url = view_context.blog_rss_feed_url

    respond_to do |format|
      format.html
      format.js
      format.rss { render layout: false }
    end
  end

  def show
    @user = blog_user
    @blog_post = blog_user.blog_posts.find(params[:id])
    @render_content_outside_container = true
    @tags = @blog_post.tags
    if !@blog_post.published? && @user != current_user
      redirect_to user_path(blog_user), notice: t('user_blog.errors.post_not_yet_published')
    end
  end

  private

  def set_theme
    @theme_name = 'user-blog'
  end

  def blog_user
    @blog_user ||= User.find(params[:user_id]).decorate
  end

  def check_blog_enabled
    if blog_user.blog.present? && !blog_user.blog.enabled? && blog_user == current_user
      redirect_to user_path(blog_user), notice: t('user_blog.errors.blog_disabled')
      return
    end

    @user_blog = blog_user.blog
    @user_blog.test_enabled
  end

  def get_blog_posts
    posts = if params[:tags].present?
      @selected_tags = Tag.where(slug: params[:tags].split(",")).pluck(:name)
      @user.published_blogs.tagged_with(@selected_tags, any: true)
    else
      @user.published_blogs
    end

    posts.paginate(page: params[:page])
  end
end
