class ThemeDrop < BaseDrop

  attr_reader :theme
  delegate :blog_url, :gplus_url, :twitter_url, :facebook_url, :support_url,
    :address, :phone_number, :site_name, :pages, to: :theme

  def initialize(theme)
    @theme = theme
  end

end
