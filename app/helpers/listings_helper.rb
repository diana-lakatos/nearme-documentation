module ListingsHelper
  def listing_inline_description(listing, length = 65)
    raw(truncate(strip_tags(listing.company_description), :length => length))
  end

  def listing_price(listing, max = nil)
    cents = listing.unit_prices.collect(&:price_cents)
    if cents.all?(&:nil?)
      "POA"
    elsif cents.all? { |p| p == 0 }
      "Free!"
    else
      prices = listing.unit_prices.reject { |p| p.price.nil? }.map do |price|
        humanized_money_with_symbol(price.price) + " " + content_tag(:span, human_friendly_time_period(price), :class => 'period')
      end

      prices[0, max || prices.length].join(';').html_safe
    end
  end

  def listing_price_show_bulk_tooltip?(listing)
    listing.unit_prices.reject { |p| p.price.nil? || p.price == 0 }.length > 1
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
