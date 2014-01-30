class PlatformContextDrop < BaseDrop
  
  attr_reader :platform_context_decorator

  delegate :name, :bookable_noun, :pages, :platform_context, :is_desksnearme, :blog_url, :twitter_url, :lessor, :lessors, :lessee, :lessees,
    :facebook_url, :address, :phone_number, :gplus_url, :site_name, :support_url, :support_email, :logo_image, :to => :platform_context_decorator


  def initialize(platform_context_decorator)
    @platform_context_decorator = platform_context_decorator
  end

  def bookable_noun_plural
    @platform_context_decorator.bookable_noun.pluralize
  end

  def logo_url
    @platform_context_decorator.logo_image.url || "https://s3.amazonaws.com/desksnearme.production/uploads/theme/logo_retina_image/1/logo_2x.png"
  end

  def host
    "http://#{platform_context_decorator.host}"
  end

  def color_black
    theme_color('black')
  end

  def color_blue
    theme_color('blue')
  end

  private

  def theme_color(color)
    @platform_context_decorator.theme.hex_color(color).presence || Theme.hexify(Theme.default_value_for_color(color))
  end

end
