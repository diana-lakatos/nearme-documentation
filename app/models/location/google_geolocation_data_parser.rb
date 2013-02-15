class Location::GoogleGeolocationDataParser

  attr :address_components, :result_hash

  MAPPING_HASH = {
    "route" => "street",
    "country" => "country",
    "locality"  =>  "city",
    "sublocality" => "suburb",
    "administrative_area_level_1" => "state",
  }


  def initialize(address_components)
    return unless address_components
    @result_hash = {}
    @address_components = address_components.to_enum.map { |c| Component.new(c[1]) }
    MAPPING_HASH.each_pair do |type, field_on_location|
      result_hash[field_on_location] = find_component_for(type).long_name
    end
  end

  def fetch_address_component(name)
    result_hash.fetch(name, nil)
  end

  private
  def find_component_for(type)
    component = address_components.find do |component|
      component.types.include?(type)
    end || Component.new({ "long_name" => "", "types" => ""})

    if type == "locality" and component.missing?
      component = find_component_for("administrative_area_level_3") 
    end
    component
  end

  class Component
    attr_reader :long_name, :types
    def initialize(hash)
      @long_name = hash.fetch("long_name", "")
      @types = hash.fetch("types", "").split(",")
    end

    def missing?
      long_name.empty?
    end
  end
end
