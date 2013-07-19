class Listing::Search::Params::Web < Listing::Search::Params
  attr :location_string

  def bounding_box
    @bounding_box ||= [[@options[:nx], @options[:ny]], [@options[:sx], @options[:sy]]] if @options[:nx].present?
    super
  end

  def midpoint
    super
    @midpoint ||= [@options[:lat], @options[:lng]] if @options[:lat].present?
    @midpoint
  end

  def get_address_component(val)
    if location
      location.address_components.fetch_address_component(val) rescue nil
    else
      options[val.to_sym]
    end
  end

  def street
    get_address_component("street")
  end

  def suburb
    get_address_component("suburb")
  end

  def city
    get_address_component("city")
  end

  def state
    get_address_component("state")
  end

  def country
    get_address_component("country")
  end
end