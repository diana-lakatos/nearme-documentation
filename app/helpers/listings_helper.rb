module ListingsHelper
  def listing_inline_description(listing, length = 65)
    raw(truncate(strip_tags(listing.company_description), :length => length))
  end

  def booking_module_class(listing)
    if listing.schedule_booking?
      'booking-fixed'
    elsif listing.action_hourly_booking?
      'booking-hourly'
    else
      'booking-daily'
    end
  end

  # Listing data for initialising a client-side bookings module
  def listing_booking_data(listing)
    base_data = {
      id: listing.id,
      name: listing.name,
      review_url: review_listing_reservations_url(listing),
      subunit_to_unit_rate: Money::Currency.new(listing.currency).subunit_to_unit,
      quantity: listing.quantity,
      initial_bookings: @initial_bookings ? @initial_bookings[listing.id] : {},
      booking_type: listing.booking_type,
      continuous_dates: listing.transactable_type.action_continuous_dates_booking,
      subscription_prices: listing.subscription_variants,
      zone_offset: listing.zone_utc_offset,
      timezone_info: listing.timezone_info,  
    }
    if listing.schedule_booking?
      base_data.merge!({
        fixed_price_cents: listing.fixed_price_cents,
        action_price_per_unit: listing.transactable_type.action_price_per_unit
      })
      base_data.merge!({
        book_it_out_discount: listing.book_it_out_discount,
        book_it_out_minimum_qty: listing.book_it_out_minimum_qty
      }) if listing.book_it_out_available?
      base_data.merge!({
        exclusive_price_cents: listing.exclusive_price_cents
      }) if listing.exclusive_price_available?
    else
      first_date = listing.first_available_date
      second_date = listing.second_available_date

      # Daily open/quantity availability data for datepickers
      today = Time.now.in_time_zone(listing.timezone).to_date
      availability = listing.availability_status_between(today, today.advance(:years => 1))

      # Initial hourly availability schedule data for hourly reservations
      hourly_availability = {
        first_date.strftime("%Y-%m-%d") => listing.hourly_availability_schedule(first_date).as_json
      } if listing.action_hourly_booking?

      base_data.merge!({
        prices_by_days: Hash[ listing.prices_by_days.map { |k, v| [k, v.cents] } ],
        availability: availability.as_json,
        minimum_date: availability.start_date,
        maximum_date: availability.end_date,
        favourable_pricing_rate: listing.favourable_pricing_rate,
        first_available_date: first_date.strftime("%Y-%m-%d"),
        second_available_date: second_date.strftime("%Y-%m-%d"),
        earliest_open_minute: listing.availability.earliest_open_minute,
        latest_close_minute: listing.availability.latest_close_minute,
        minimum_booking_days: listing.minimum_booking_days,
        minimum_booking_minutes: listing.minimum_booking_minutes,
        hourly_availability_schedule_url: hourly_availability_schedule_listing_reservations_url(listing, format: :json),
        action_hourly_booking: listing.action_hourly_booking? && listing.hourly_price_cents.to_i > 0,
        action_daily_booking: listing.action_daily_booking?,
        hourly_price_cents: listing.hourly_price_cents,
        hourly_availability_schedule: hourly_availability,
      })
    end
    base_data

  end

  def strip_http(url)
    url.gsub(/https?:\/\/(www\.)?/, "").gsub(/\/$/, "")
  end

  def listing_data_attributes(listing = @listing)
    {
      :'data-listing-id' => listing.id
    }
  end

  def selected_listing_siblings(location, listing, user = current_user)
    @siblings ||= ((user and user.companies.first == location.company) ? location.listings.active : location.listings.visible)  - [listing]
  end

  def space_listing_placeholder_path(options = {})
    Placeholder.new(height: options[:height], width: options[:width]).path
  end

  def connection_tooltip_for(connections, size = 5)
    difference = connections.size - size
    connections = connections.first(5)
    connections << t('search.list.additional_social_connections', count: difference) if difference > 0
    connections.join('<br />').html_safe
  end

  def connections_for(listing, current_user)
    find_connections_for(listing, current_user)
  end

  private

  def find_connections_for(listing, current_user)
    return [] if current_user.nil? || current_user.friends.count.zero?

    friends = current_user.friends.visited_listing(listing).collect do |user|
      "#{user.name} worked here";
    end

    hosts = current_user.friends.hosts_of_listing(listing).collect do |user|
      "#{user.name} is the host"
    end

    host_friends = current_user.friends_know_host_of(listing).collect do |user|
      "#{user.name} knows the host"
    end

    mutual_visitors = current_user.mutual_friends.visited_listing(listing).collect do |user|
      next unless user.mutual_friendship_source
      "#{user.mutual_friendship_source.name} knows #{user.name} who worked here"
    end

    [friends, hosts, host_friends, mutual_visitors].flatten
  end

  def dimensions_templates_collection
    (@platform_context.instance.dimensions_templates + current_user.dimensions_templates).map do |dt|
      ["#{dt.name} (#{dt.height} #{t(dt.height_unit, scope: 'measure_units.length')} x #{dt.width} #{t(dt.width_unit, scope: 'measure_units.length')} x #{dt.depth} #{t(dt.depth_unit, scope: 'measure_units.length')}, #{dt.weight} #{t(dt.weight_unit, scope: 'measure_units.weight')})", dt.id]
    end
  end

end
