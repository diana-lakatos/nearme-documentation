module LiquidFilters

  def shorten_url(url)
    Rails.env.development? ? url : Googl.shorten(url).short_url
  end

  def translate(key, options={})
    I18n.t(key, options.deep_symbolize_keys)
  end

  alias_method :t, :translate
end

