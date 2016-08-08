require 'will_paginate/array'

class Blog::BlogPostsController < Blog::ApplicationController

  before_filter :redirect_if_disabled
  before_filter :find_post, :only => [:show]

  def index
    @tags = Tag.for_instance_blog.alphabetically
    @blog_posts = get_blog_posts
    @blog_rss_feed_url = view_context.blog_rss_feed_url
    respond_to do |format|
      format.html { render :index }
      format.rss { render layout: false }
    end
  end

  def show
    @tags = @blog_post.tags
  end

  private

  def find_post
    @blog_post = begin
                   @blog_instance.blog_posts.find(params[:id])
                 rescue ActiveRecord::RecordNotFound
                   instance.user_blog_posts.find(params[:id])
                 end
    # a 301 redirect that uses the current friendly id.
    if ![blog_post_path(@blog_post), blog_post_path(@blog_post, language: I18n.locale)].include?(request.path)
      return redirect_to @blog_post, :status => :moved_permanently
    end if @blog_post.kind_of?(BlogPost)
  end

  def instance
    @instance ||= PlatformContext.current.instance
  end

  def redirect_if_disabled
    return if @blog_instance.enabled?
    flash[:notice] = 'This blog is currently inactive.'
    redirect_to root_path
  end

  def get_blog_posts
    @instance_blog_posts = @blog_instance.blog_posts.published
    @user_blog_posts = instance.user_blog_posts.includes(:user).published.highlighted

    posts = if params[:tags].present?
      @selected_tags = Tag.where(slug: params[:tags].split(",")).pluck(:name)
      @instance_blog_posts.tagged_with(@selected_tags, any: true) + @user_blog_posts.tagged_with(@selected_tags, any: true)
    else
      @instance_blog_posts + @user_blog_posts
    end

    posts.sort_by(&:published_at).reverse.paginate(page: params[:page], per_page: 10)
  end
end
