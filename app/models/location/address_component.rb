module Location::AddressComponent
  class AddressComponentHash

    IMPORTANT_TYPES = {
      "route" => "street",
      "country" => "country",
      "locality"  =>  "city",
      "sublocality" => "suburb",
      "administrative_area_level_1" => "state",
      "postal_code"=>"zip",
      "street_address" => "address_long"
    }

    def initialize()
      @hash = {}
      @already_parsed = {}
      @current_index = 0
      @available_types = IMPORTANT_TYPES.keys
    end

    def add(address_component)
      unless((important_types = (@available_types & address_component["types"].split(","))).empty?)
        important_types.each do |important_type|
          @hash[IMPORTANT_TYPES[important_type]] = address_component["long_name"]
        end
      end
    end

    def get_result
      @hash
    end

    def map_geocder_field(field)
      $fields_mapping[field] ? $fields_mapping : nil
    end

  end

  class Parser

    def self.parse_geocoder_address_component_hash(hash = {})
      address_component_hash = Location::AddressComponent::AddressComponentHash.new
      hash.each do |index, address_component|
        address_component_hash.add(address_component)
      end
      address_component_hash.get_result
    end

  end

end
