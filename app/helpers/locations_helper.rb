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
      listing_booking_data(listing)
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
