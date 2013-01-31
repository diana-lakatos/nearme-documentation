class Location::GoogleGeolocationDataParser

  def initialize(address_components)
    init
    parse(address_components)
  end

  def init
    @available_types = Location::SUPPORTED_FIELDS.keys
  end

  def parse(address_components)
    address_components.each do |index, address_component|
      extract_component(address_component)
    end if address_components
  end



  def extract_component(address_component)
    types = ( address_component["types"].kind_of?(String) ? address_component["types"].split(",") : address_component["types"])
    if types
      unless (important_types = (@available_types & types)).empty?
        important_types.each do |important_type|
          attribute = Location::SUPPORTED_FIELDS[important_type]
          self.class.send(:attr_accessor, attribute)
          self.send("#{attribute}=", address_component["long_name"])
        end
      end
    end
  end

end

