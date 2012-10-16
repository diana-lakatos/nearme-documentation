module ListingsHelper
  def listing_inline_description(listing, length = 65)
    raw(truncate(strip_tags(listing.company_description), :length => length))
  end

  def listing_price(listing)
    cents = listing.unit_prices.collect(&:price_cents)
    if cents.all?(&:nil?)
      "POA"
    elsif cents.all? { |p| p == 0 }
      "Free!"
    else
      listing.unit_prices.reject { |p| p.price.nil? }.map do |price|
        humanized_money_with_symbol(price.price) +" #{human_friendly_time_period(price)}"
      end.join("; ")
    end
  end

  def human_friendly_time_period(unit_price)
    case unit_price.period
    when Listing::MINUTES_IN_DAY
      "per day"
    when Listing::MINUTES_IN_WEEK
      "per week"
    when Listing::MINUTES_IN_MONTH
      "per month"
    end
  end

  def strip_http(url)
    url.gsub(/https?:\/\/(www\.)?/, "").gsub(/\/$/, "")
  end
end
