module LocationsHelper
  def location_format_address(address)
    parts = address.split(',')

    content = content_tag(:strong, parts[0])

    if parts.length > 1
      content += content_tag(:span, ", #{parts[1, parts.length].join(', ')}")
    end
    content
  end

  def location_listings_json(location = @location)
    location.listings.map { |listing|
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
        ]
      }
    }.to_json
  end

  def location_contact_phone(location)
    if location.phone.present?
      content_tag(:p,
        content_tag(:span, location.phone, class: 'ico-phone padding')
      )
    end
  end

  def location_contact_email(location)
    if location.email.present?
      content_tag(:p,
        content_tag(:span, location.email, class: 'ico-mail padding')
      )
    end
  end

end
