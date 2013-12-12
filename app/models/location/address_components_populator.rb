class Location::AddressComponentsPopulator

  LIMIT = 100

  attr_accessor :result

  def initialize(location = nil, options = {})
    @location = location

    @use_limit = options[:use_limit] || false
    @show_inspections = options[:show_inspections] || false

    @@current_geocoding ||= 0 if @use_limit
  end

  def perform
    geocode
    populate
  end

  def geocode
    raise 'Limit reached' if @use_limit && @@current_geocoding > LIMIT

    @result = Geocoder.search(@location.read_attribute(:address)).first
    if @result
      output "Geocoded and fetched address_components for #{location_info}"
    else
      output "Couldn't geocode and get address_components for #{location_info}"
    end
    @@current_geocoding += 1 if @use_limit
    @result
  end

  def populate
    return if @location.formatted_address.blank? || @location.address_components.present?
    if result
      @location.address_components = wrapped_address_components
      output "###### address_components: #{@location.address_components}"
      if @location.save
        output "###### and saved successfuly"
      else
        output "###### but couldn't save: #{@location.errors.full_messages.inspect}"
      end
      output ""
    end
  end

  def wrapped_address_components
    wrapper_hash = {}
    @result.address_components.each_with_index do |address_component_hash, index|
      wrapper_hash["#{index}"] = address_component_hash
    end
    wrapper_hash
  end

  def self.wrapped_address_components(geocoded)
    instance = new
    instance.result = geocoded
    instance.wrapped_address_components
  end

  private
  def location_info
    return nil if @location.blank?
    "#{@location.id}: #{@location.address}; coordinates: '#{@location.latitude}, #{@location.longitude}'"
  end

  def output(string)
    puts string if @show_inspections
  end

end
