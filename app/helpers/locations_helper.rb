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
      {
        :id => listing.id,
        :name => listing.name,
        :first_available_date => listing.first_available_date.strftime("%Y/%m/%d"),
        :prices => listing.period_prices.reject { |period, price| price.nil? || price.cents <= 0 }.map { |period, price|
          {
            :price_cents => price.cents,
            :period      => period.to_i,
            :currency_code   => price.currency.iso_code,
            :currency_symbol => price.currency.symbol
          }
        }
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
