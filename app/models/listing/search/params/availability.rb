class Listing::Search::Params::Availability
  attr :min, :start, :finish
  def initialize(hash)
    @min = from_quantity(hash.fetch(:quantity, { min: 1 }))
    extract_dates(hash[:dates])
  end

  def dates
    @dates
  end

  def from_quantity(quantity)
    if quantity.respond_to? :fetch
      quantity.fetch(:min, 1).to_i
    else
      quantity.to_i
    end
  end

  private

  def extract_dates(dates = {})
    if dates.is_a? Array
      @dates.map { |d| coerce_date(d) } if dates.is_a? Array
    elsif dates.is_a?(Hash) && dates[:start].present? && dates[:end].present?
      start = coerce_date(dates[:start])
      finish = coerce_date(dates[:end])
      @dates = (start...finish)
    else
      @dates = default_dates
    end
  end

  def coerce_date(date)
    date.respond_to?(:gsub) ? Date.parse(date) : date
  end

  def default_dates
    []
  end
end

class Listing::Search::Params::NullAvailability
  def min
    1
  end

  def dates
    []
  end
end
