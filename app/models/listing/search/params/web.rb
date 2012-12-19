class Listing::Search::Params::Web < Listing::Search::Params
  attr :location_string

  def found_location?
    @found_location
  end

  def provided_boundingbox
    [options[:nx], options[:ny],options[:sx], options[:sy]]
  end

  def provided_midpoint
    [options[:lat], options[:lng]]
  end
end
