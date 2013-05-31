
class DataImporter::CsvToXmlConverter

  def initialize(csv_file, output_path)
    @csv_file = csv_file
    @output_path = output_path
    @last_company = nil
    @last_location = nil
  end

  def add_object(klass, builder, &block)
    klass_symbol = klass.name.underscore.to_sym
    insert_to_xml(klass_symbol, klass.xml_attributes, @hash[klass_symbol], builder, &block)
  end

  def insert_to_xml(node_name, attributes, attributes_data, builder, &block)
    builder.send(node_name, (attributes_data[:external_id] ? {:id => attributes_data[:external_id]} : {} )) do |o|
      attributes.each do |attribute|
        o.send(attribute) { |field| field.cdata(attributes_data[attribute]) }
      end
      yield if block_given?
    end
  end

  def add_availabilities(builder, scope)
    @hash[scope][:availability_rule_attributes].each do |availability_attributes|
      insert_to_xml(:availability_rule, AvailabilityRule.xml_attributes, availability_attributes, builder)
    end if @hash[scope][:availability_rule_attributes]
  end

  def add_amenities(builder, scope)
    @hash[scope][:amenities].each do |amenity|
      unless amenity_already_added?(amenity)
        insert_to_xml(:amenity, [:name], {:name => amenity}, builder)
      end
    end if @hash[scope][:amenities]
  end

  def convert
    File.open(@output_path, 'w') do |f| 
      f << Nokogiri::XML::Builder.new do |xml|
        @xml = xml
        build_xml
      end.to_xml
    end
  end

  def build_xml
    @xml.companies(:tenant => @csv_file.tenant_name) {
      while @csv_file.next_row
        @hash = @csv_file.row_as_hash
        build_company do
          build_location do
            build_availabilities if new_location?
            build_amenities
            build_listing do
              build_availabilities
            end
            store_last_location
          end
        end
      end
    }
  end

  def build_company
    # if company external id is different than the previous one, it means we need to create new company
    if new_company?
      add_object(Company, @xml) do
        # we want to insert locations inside this company, we need builder for this
        @xml.locations do |locations|
          @location_builder = Nokogiri::XML::Builder.new({}, locations.parent)
        end
      end
    end
    yield
  end

  def build_location
    # if address for location is different than the previous one, it means we need to create new location
    @scope = :location
    if new_location?
      add_object(Location, @location_builder) do
        # we want to insert listings inside this location, we need builder for this
        @listing_builder = add_node(@location_builder, 'listings')
        @availability_builder = add_node(@location_builder, 'availability_rules')
        @amenity_builder = add_node(@location_builder, 'amenities')
      end
    end
    yield
  end

  def add_node(builder, name)
    builder.send(name) do |new_node|
      @new_builder = Nokogiri::XML::Builder.new({}, new_node.parent)
    end
    @new_builder
  end

  def build_availabilities
    add_availabilities(@availability_builder, @scope)
  end

  def new_location?
    if @last_location != @hash[:location][:address]
      clear_amenities
      true
    else
      false
    end
  end

  def store_last_location
      @last_location = @hash[:location][:address]
  end

  def clear_amenities
    @stored_amenities = []
  end
  
  def store_amenity(amenity)
    @stored_amenities << amenity
  end

  def amenity_already_added?(amenity)
    @stored_amenities.include?(amenity).tap do |already_stored|
      @stored_amenities << amenity unless already_stored
    end
  end

  def new_company?
    if @last_company != @csv_file.send(:company_attributes)[:external_id]
      @last_company = @hash[:company][:external_id]
      @last_location = nil
      true
    else
      false
    end
  end

  def build_amenities
    add_amenities(@amenity_builder, @scope)
  end

  def build_listing
    @scope = :listing
    add_object(Listing, @listing_builder) do 
      @listing_builder.availability_rules do |availabilities|
        @availability_builder = Nokogiri::XML::Builder.new({}, availabilities.parent)
      end
    end
    yield
  end

end

