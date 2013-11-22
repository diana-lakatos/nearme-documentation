class ThemeDrop < BaseDrop

  def initialize(theme)
    @theme = theme
  end

  def blog_url
    @theme.blog_url.to_s
  end

  def gplus_url
    @theme.gplus_url.to_s
  end

  def twitter_url
    @theme.twitter_url.to_s
  end

  def facebook_url
    @theme.facebook_url.to_s
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
    @theme.pages
  end

  def support_url
    @theme.support_url
  end

end
