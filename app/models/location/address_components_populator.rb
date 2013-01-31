class Location::AddressComponentsPopulator

  LIMIT = 2

  def initialize
    @current_geocoding = 0
  end

  def populate(location)
    @location = location
    raise_if_limit_reached
    if @location.formatted_address && !@location.address_components
      if (@result = get_geocoding_result)
        @location.address_components = wrap_result_address_components
        @location.save!
      end
    end
  end

  def get_geocoding_result
    result = Geocoder.search(@location.formatted_address).first
    @current_geocoding += 1
    result
  end

  def raise_if_limit_reached
    raise('Limit reached') unless @current_geocoding < LIMIT
  end

  def wrap_result_address_components
    wrapper_hash = {}
    @result.address_components.each_with_index do |address_component_hash, index|
      wrapper_hash["#{index}"] = address_component_hash
    end
    wrapper_hash
  end

end

