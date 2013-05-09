module ListingsHelper
  def listing_inline_description(listing, length = 65)
    raw(truncate(strip_tags(listing.company_description), :length => length))
  end

  # Listing data for initialising a client-side bookings module
  def listing_booking_data(listing)
    availability = listing.availability_status_between(Date.today, Date.today.advance(:years => 1))
    {
      :id => listing.id,
      :name => listing.name,
      :review_url => review_listing_reservations_url(listing),
      :first_available_date => listing.first_available_date.strftime("%Y-%m-%d"),
      :minimum_booking_days => listing.minimum_booking_days,
      :quantity => listing.quantity,
      :availability => availability.as_json,
      :minimum_date => availability.start_date,
      :maximum_date => availability.end_date,
      :prices_by_days => Hash[
        listing.prices_by_days.map { |k, v| [k, v.cents] }
      ],
      :initial_bookings => @initial_bookings ? @initial_bookings[listing.id] : {}
    }
  end

  def listing_price(listing, max = nil)
    cents = [listing.daily_price_cents, listing.weekly_price_cents, listing.monthly_price_cents]
    if cents.all?(&:nil?)
      "Call"
    elsif cents.all? { |p| p == 0 }
      "Free!"
    else
      prices = listing.period_prices.reject { |key, price| p.nil? }.map do |period, price|
        humanized_money_with_symbol(price) + " " + content_tag(:span, phuman_friendly_time_perio(period), :class => 'period')
      end

      prices[0, max || prices.length].join(';').html_safe
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

  def listing_price_show_bulk_tooltip?(listing)
    listing.prices.reject { |p| p.nil? || p == 0 }.length > 1
  end

  def strip_http(url)
    url.gsub(/https?:\/\/(www\.)?/, "").gsub(/\/$/, "")
  end

  def listing_data_attributes(listing = @listing)
    {
      :'data-listing-id' => listing.id
    }
  end

end
