class PlatformContextDrop < BaseDrop
  delegate :name, :bookable_noun, :pages, :platform_context, :is_desksnearme, :blog_url, :twitter_url, 
    :facebook_url, :address, :phone_number, :gplus_url, :site_name, :to => :platform_context_decorator
  
  def initialize(platform_context_decorator)
    @platform_context_decorator = platform_context_decorator
  end

  def bookable_noun_plural
    @platform_context_decorator.bookable_noun.pluralize
  end

  private
  def platform_context_decorator
    @platform_context_decorator
  end
end
