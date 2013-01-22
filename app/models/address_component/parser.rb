module AddressComponent

  class AddressComponentHash

    def initialize()
      @hash = {}
      @already_parsed = {}
      @current_index = 0
    end

    def add(address_component)
      types = address_component["types"].split(",")
      key = address_component["short_name"] + address_component["long_name"]
      if (existing_index = @already_parsed[key]).nil?
        @hash[@current_index] = {
          "short_name" => address_component["short_name"],
          "long_name" => address_component["long_name"],
          "types" => types
        }
        @already_parsed[key] = @current_index 
        @current_index += 1
      else
        # |= will add elements without duplictes, [1, 3] | [2, 1] results in [1, 3, 2]
        @hash[existing_index]["types"] |= types
      end
    end

    def get_result
      @hash
    end

  end

  class Parser

    def self.parse_geocoder_address_component_hash(hash)
      address_component_hash = AddressComponent::AddressComponentHash.new

      hash.each do |index, address_component|
        address_component_hash.add(address_component)
      end
      address_component_hash.get_result
    end

  end
end
