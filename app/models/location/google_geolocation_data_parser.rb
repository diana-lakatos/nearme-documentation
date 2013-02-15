class Location::GoogleGeolocationDataParser

  MAPPING_HASH = {
    "route" => "street",
    "country" => "country",
    "locality"  =>  "city",
    "sublocality" => "suburb",
    "administrative_area_level_1" => "state",
  }

  BACKUP_HASH = {
    "administrative_area_level_3" => "city"
  }


  def initialize(address_components)
    init
    @result_hash = {}
    @backup_hash = {}
    parse(address_components)
  end

  def init
    @available_types = MAPPING_HASH.keys
    @backup_types = BACKUP_HASH.keys
  end

  def parse(address_components)
    if address_components
      address_components.each do |index, address_component|
        @address_component = address_component
        extract_component
      end
      apply_backup
    end
  end


  def extract_component
    if !(important_types = get_important_types).empty?
      important_types.each do |important_type|
        @result_hash[MAPPING_HASH[important_type].downcase] = @address_component["long_name"]
      end
    elsif !(backup_types = get_backup_types).empty?
      backup_types.each do |backup_type|
        Rails.logger.debug 'replacing'
        @backup_hash[BACKUP_HASH[backup_type]] = @address_component["long_name"]
      end
    end
  end

  def apply_backup
    @backup_hash.each do |key, value|
      @result_hash[key] = value unless @result_hash[key]
    end
  
  end

  def fetch_address_component(string)
    @result_hash[string]
  end

  def get_important_types
    @available_types & get_address_component_types
  end

  def get_backup_types
    @backup_types & get_address_component_types
  end

  def get_address_component_types
    return [] unless @address_component["types"].present?
    @address_component["types"].kind_of?(String) ? @address_component["types"].split(",") : @address_component["types"]
  end

end

