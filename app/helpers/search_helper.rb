module SearchHelper
  # Special geolocation fields for the search form(s)
  def search_geofields
    %w(lat lng nx ny sx sy)
  end

  def search_availability_date(date)
    date ? date.strftime('%b %e') : ''
  end

  def search_availability_quantity
    params[:availability].present? && params[:availability][:quantity].to_i || 1
  end

  def search_amenities
    params[:amenities].present? && params[:amenities].map(&:to_i) || []
  end

  def search_price_min
    (params[:price].present? && params[:price][:min]) || 0
  end

  def search_price_max
    params[:price].present? && params[:price][:max] || PriceRange::MAX_SEARCHABLE_PRICE
  end

end
