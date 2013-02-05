class Location::GoogleGeolocationDataParser

  MAPPING_HASH = {
    "route" => "street",
    "country" => "country",
    "locality"  =>  "city",
    "sublocality" => "suburb",
    "administrative_area_level_1" => "state",
  }


  def initialize(address_components)
    init
    @result_hash = {}
    parse(address_components)
  end

  def init
    @available_types = MAPPING_HASH.keys
  end

  def parse(address_components)
    address_components.each do |index, address_component|
      @address_component = address_component
      extract_component
    end if address_components
  end


  def extract_component
    important_types = get_important_types
    unless important_types.empty?
      important_types.each do |important_type|
        @result_hash[MAPPING_HASH[important_type].downcase] = @address_component["long_name"]
      end
    end
  end

  def fetch_address_component(string)
    @result_hash[string]
  end

  def get_important_types
    @available_types & get_address_component_types
  end

  def get_address_component_types
    return [] unless @address_component["types"].present?
    @address_component["types"].kind_of?(String) ? @address_component["types"].split(",") : @address_component["types"]
  end

end

