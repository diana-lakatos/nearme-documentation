class ThemeDrop < BaseDrop
  attr_reader :theme

  # blog_url
  #   url to this marketplace's blog
  # gplus_url
  #   url to this marketplace's Google Plus page
  # twitter_url
  #   url to this marketplace's twitter page
  # facebook_url
  #   url to this marketplace's facebook page
  # support_url
  #   url to this marketplace's support page
  # address
  #   address of the entity behind this marketplace
  # phone_number
  #   phone number of the entity behind this marketplace
  # site_name
  #   name of the marketplace
  # pages
  #   array of pages created for this marketplace by the marketplace admin
  delegate :blog_url, :gplus_url, :twitter_url, :facebook_url, :support_url,
           :address, :phone_number, :site_name, :pages, to: :theme

  def initialize(theme)
    @theme = theme
  end
end
