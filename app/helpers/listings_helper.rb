module ListingsHelper
  def listing_inline_description(listing, length = 65)
    raw(truncate(strip_tags(listing.company_description), :length => length))
  end

  # Listing data for initialising a client-side bookings module
  def listing_booking_data(listing)
    first_date = listing.first_available_date

    # Daily open/quantity availability data for datepickers
    availability = listing.availability_status_between(Time.zone.today, Time.zone.today.advance(:years => 1))

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

    host_friends = current_user.friends.know_host_of(listing).collect do |user|
      "#{user.name} knows the host"
    end

    mutual_visitors = current_user.mutual_friends.visited_listing(listing).collect do |user|
      next unless user.mutual_friendship_source
      "#{user.mutual_friendship_source.name} knows #{user.name} who worked here"
    end

    [friends, hosts, host_friends, mutual_visitors].flatten
  end

end
