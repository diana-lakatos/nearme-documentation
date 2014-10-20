module LiquidFilters

  def shorten_url(url)
    Googl.shorten(url).short_url
  end
end

