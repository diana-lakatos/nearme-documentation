class Address::GoogleGeolocationDataParser
  attr_reader :address_components, :result_hash

  MAPPING_HASH = {
    'route' => 'street',
    'country' => 'country',
    'locality'  =>  'city',
    'sublocality' => 'suburb',
    'administrative_area_level_1' => 'state',
    'postal_code' => 'postcode',
    'street_number' => 'street_number'
  }

  def initialize(address_components)
    @result_hash = {}
    return unless address_components
    @address_components = address_components.to_enum.map { |c| Component.new(c[1]) }
    MAPPING_HASH.each_pair do |type, field_on_location|
      component = find_component_for(type)
      result_hash[field_on_location] = { long: component.long_name, short: component.short_name }
    end
  end

  def fetch_address_component(name, name_type = :long)
    result_hash.fetch(name, {}).fetch(name_type, nil)
  end

  private

  def find_component_for(type)
    component = address_components.find do |component|
      component.types.include?(type)
    end || Component.new('long_name' => '', 'short_name' => '', 'types' => '')

    if type == 'locality' && component.missing?
      component = find_component_for('administrative_area_level_3')
    end
    if type == 'sublocality' && component.missing?
      component = find_component_for('neighborhood')
    end

    if type == 'sublocality' && component.missing?
      component = find_component_for('locality')
    end

    component
  rescue
    Component.new('long_name' => '', 'short_name' => '', 'types' => '')
  end

  class Component
    attr_reader :long_name, :short_name, :types
    def initialize(hash)
      @long_name = hash.fetch('long_name', '')
      @short_name = hash.fetch('short_name', '')
      @types = hash.fetch('types', '').split(',')[0]
    end

    def missing?
      long_name.empty?
    end
  end
end
