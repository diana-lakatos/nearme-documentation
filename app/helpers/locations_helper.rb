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
        :prices => listing.unit_prices.reject { |unit_price| unit_price.price.nil? }.map { |unit_price|
          {
            :price_cents => unit_price.price_cents,
            :period      => unit_price.period,
            :currency_code   => unit_price.price.currency.iso_code,
            :currency_symbol => unit_price.price.currency.symbol
          }
        }
      }
    }.to_json
  end
end
