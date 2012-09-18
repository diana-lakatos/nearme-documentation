module ListingsHelper
  def listing_inline_description(listing, length = 65)
    raw(truncate(strip_tags(listing.company_description), :length => length))
  end

  def listing_price(listing)
    if(listing.price_cents == 0)
      "Free!"
    else
      humanized_money_with_symbol(listing.price)
    end
  end

  def strip_http(url)
    url.gsub(/https?:\/\/(www\.)?/, "").gsub(/\/$/, "")
  end
end
