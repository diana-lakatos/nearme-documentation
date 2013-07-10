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

  def address_components
    @location.address_components
  end

  def suburb
    address_components.result_hash.fetch('suburb') rescue nil
  end

  def city
    address_components.result_hash.fetch('city') rescue nil
  end

  def state
    address_components.result_hash.fetch('state') rescue nil
  end

  def country
    address_components.result_hash.fetch('country') rescue nil
  end
end
