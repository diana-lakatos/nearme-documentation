class Blog::ApplicationController < ApplicationController

  before_filter :find_blog_instance

  layout 'blog'

  private

  def find_blog_instance
    @blog_instance = if near_me?
                       BlogInstance.where(owner_type: 'near-me').first
                     else
                       platform_context.instance.blog_instance
                     end
  end

  def platform_context
    if near_me?
      @platform_context ||= PlatformContext.new(Instance.default_instance)
    else
      super
    end
  end

  def near_me?
    request.host == 'near-me.com'
  end

end
