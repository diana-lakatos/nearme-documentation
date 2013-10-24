class ThemeDrop < BaseDrop

  def initialize(theme)
    @theme = theme
  end

  def blog_url
    @theme.blog_url
  end

  def twitter_url
    @theme.twitter_url
  end

  def facebook_url
    @theme.facebook_url
  end

  def is_desksnearme?
    @theme.is_desksnearme?
  end 

  def address
    @theme.address
  end

  def phone_number
    @theme.phone_number
  end

  def site_name
    @theme.site_name
  end

  def pages
    @theme.pages_with_fallbacks
  end

  def support_url
    @theme.support_url
  end

end
