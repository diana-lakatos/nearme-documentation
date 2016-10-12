module Blog::ApplicationHelper
  def blog_title(page_title)
    content_for :title, page_title
  end

  def blog_title_tag
    @blog = get_blog_instance
    content_for?(:title) ? content_for(:title) + ' | ' + @blog.name : @blog.name
  end

  def blog_rss_title
    @blog = get_blog_instance
    if params[:tags].present?
      @blog.name + ' | ' + @selected_tags.map(&:capitalize).join(', ')
    else
      @blog.name
    end
  end

  def blog_rss_url(format: false)
    base_url = format ? canonical_blog_url + '.rss' : canonical_blog_url

    if params[:tags].present?
      base_url + "?tags=#{params[:tags]}"
    else
      base_url
    end
  end

  def blog_rss_post_url(post)
    if @blog_instance.present?
      base_url + blog_post_path(post)
    else
      base_url + user_blog_post_show_path(@user, post)
    end
  end

  def blog_rss_feed_url
    blog_rss_url(format: true)
  end

  private

  def get_blog_instance
    @blog_instance.present? ? @blog_instance : @user_blog
  end

  def canonical_blog_url
    if @blog_instance.present?
      base_url + blog_posts_path
    else
      base_url + user_blog_posts_list_path(@user)
    end
  end

  def base_url
    request.protocol + platform_context.host
  end
end
