class Listing::Search::Params::Web < Listing::Search::Params
  attr :location_string

  # Web searches are always only geo-location based lookups at this stage.
  def keyword_search?
    false
  end

  def bounding_box
    @bounding_box ||= [[@options[:nx], @options[:ny]], [@options[:sx], @options[:sy]]] if @options[:nx].present?
    super
  end

  def midpoint
    super
    @midpoint ||= [@options[:lat], @options[:lng]] if @options[:lat].present?
    @midpoint
  end

  def address_components
    @address_components || {
      "street" => "Unknown",
      "country" => "Unknown",
      "city" => "Unknown",
      "suburb" => "Unknown",
      "state" => "Unknown"
    }
  end

end
