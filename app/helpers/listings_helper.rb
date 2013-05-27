module ListingsHelper
  def listing_inline_description(listing, length = 65)
    raw(truncate(strip_tags(listing.company_description), :length => length))
  end

  # Listing data for initialising a client-side bookings module
  def listing_booking_data(listing)
    first_date = listing.first_available_date

    # Daily open/quantity availability data for datepickers
    availability = listing.availability_status_between(Date.today, Date.today.advance(:years => 1))

    # Initial hourly availability schedule data for hourly reservations
    hourly_availability = {
      first_date.strftime("%Y-%m-%d") => listing.hourly_availability_schedule(first_date).as_json
    } if listing.hourly_reservations?

    {
      :id => listing.id,
      :name => listing.name,
      :review_url => review_listing_reservations_url(listing),
      :hourly_availability_schedule_url => hourly_availability_schedule_listing_reservations_url(listing, :format => :json),
      :first_available_date => first_date.strftime("%Y-%m-%d"),
      :hourly_reservations => listing.hourly_reservations?,
      :hourly_price_cents => listing.hourly_price_cents,
      :hourly_availability_schedule => hourly_availability,
      :earliest_open_minute => listing.availability.earliest_open_minute,
      :latest_close_minute => listing.availability.latest_close_minute,
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

  def  selected_listing_siblings(location, listing)
    @siblings ||= location.listings - [listing]
  end

end
