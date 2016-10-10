class DataImporter::CsvToXmlConverter
  def initialize(csv_file, output_path, transactable_type)
    @csv_file = csv_file
    @output_path = output_path
    @last_company = nil
    @last_location = nil
    @transactable_type = transactable_type
    @xml_attributes = {}
  end

  def add_object(klass, builder, options = {}, &block)
    klass_symbol = options.fetch(:klass_symbol, klass.name.underscore.to_sym)
    if klass_symbol == :listing
      @xml_attributes[klass_symbol] ||= klass.xml_attributes(@transactable_type)
    else
      @xml_attributes[klass_symbol] ||= klass.xml_attributes
    end
    attributes_names = @xml_attributes[klass_symbol]
    attributes_values = @hash[klass_symbol]

    if options.fetch(:new_node, true)
      insert_with_new_node(options.fetch(:node_name, klass_symbol), attributes_names, attributes_values, builder, &block)
    else
      insert_to_xml(attributes_names, attributes_values, builder, &block)
    end
  end

  def insert_with_new_node(node_name, attributes, attributes_data, builder, &_block)
    builder.send(node_name, (attributes_data[:external_id] ? { id: attributes_data[:external_id] } : {})) do |o|
      insert_to_xml(attributes, attributes_data, o)
      yield if block_given?
    end
  end

  def insert_to_xml(attributes, attributes_data, builder)
    attributes.each do |attribute|
      if attribute.to_s == 'test'
        builder.test { |field| field.cdata(attributes_data[attribute].strip) } if attributes_data[attribute].try(:strip).present?
      else
        builder.send(attribute) { |field| field.cdata(attributes_data[attribute].strip) } if attributes_data[attribute].try(:strip).present?
      end
    end
  end

  def add_availabilities(builder, scope)
    @hash[scope][:availability_rule_attributes].each do |availability_attributes|
      insert_with_new_node(:availability_rule, AvailabilityRule.xml_attributes, availability_attributes, builder)
    end if @hash[scope][:availability_rule_attributes]
  end

  def add_action_type(builder, scope)
    return unless builder.parent.search('pricings').blank?
    pricings = []
    @hash[scope].select { |k, v| k =~ /_price_cents/ && v.to_i > 0 }.each do |pricing|
      number_of_units, unit = pricing.first.to_s.match(/for_(\d*)_(\w*)_price_cents/)[1..2]
      pricings << {
        enabled: true,
        number_of_units: number_of_units,
        unit: unit,
        price_cents: pricing.last
      }
    end

    if pricings.any?
      type = case pricings.last[:unit]
        when 'event'
          'Transactable::EventBooking'
        when /subscription/
          'Transactable::SubscriptionBooking'
        else
          'Transactable::TimeBasedBooking'
        end
      insert_to_xml([:type], { type: type }, builder)

      builder.availability_rules do |availabilities|
        @availability_builder = Nokogiri::XML::Builder.new({}, availabilities.parent)
      end

      builder.pricings do
        pricings.each do |price|
          builder.pricing do
            insert_to_xml(price.keys, price, builder)
          end
        end
      end
    end
  end

  def add_amenities(builder, scope)
    @hash[scope][:amenities].each do |amenity|
      unless amenity_already_added?(amenity)
        insert_with_new_node(:amenity, [:name], { name: amenity }, builder)
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
    @xml.companies do
      while @csv_file.next_row
        @hash = @csv_file.row_as_hash
        build_company do
          build_user
          build_location do
            build_address if new_location?
            build_availabilities if new_location?
            build_amenities
            build_listing do
              build_photos
              build_action_type do
                build_availabilities
              end
            end
            store_last_location
          end
        end
      end
    end
  end

  def build_company
    # if company external id is different than the previous one, it means we need to create new company
    if new_company?
      add_object(Company, @xml) do
        @xml.users do |users|
          @user_builder = Nokogiri::XML::Builder.new({}, users.parent)
        end
        @xml.locations do |locations|
          @location_builder = Nokogiri::XML::Builder.new({}, locations.parent)
        end
      end
    end
    yield
  end

  def build_user
    add_object(User, @user_builder) if new_user?
  end

  def build_location
    # if address for location is different than the previous one, it means we need to create new location
    @scope = :location
    if new_location? && @hash[:location][:external_id].present?
      add_object(Location, @location_builder) do
        # we want to insert listings inside this location, we need builder for this
        @address_builder = add_node(@location_builder, 'location_address')
        @listing_builder = add_node(@location_builder, 'listings')
        @availability_builder = add_node(@location_builder, 'availability_rules')
        @amenity_builder = add_node(@location_builder, 'amenities')
      end
    end
    yield if @hash[:location][:external_id].present?
  end

  def build_action_type
    add_action_type(@action_type_builder, @scope)
  end

  def build_address
    add_object(Address, @address_builder, new_node: false)
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
    if @last_location != @hash[:location][:external_id]
      @last_listing = nil
      clear_amenities
      true
    else
      false
    end
  end

  def store_last_location
    @last_location = @hash[:location][:external_id]
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
    if !@hash[:company][:external_id] || @last_company != @hash[:company][:external_id]
      @last_company = @hash[:company][:external_id]
      @last_location = nil
      @last_listing = nil
      @last_user = nil
      true
    else
      false
    end
  end

  def new_listing?
    if !@hash[:listing][:external_id] || @last_listing != @hash[:listing][:external_id]
      @last_listing = @hash[:listing][:external_id]
      true
    else
      false
    end
  end

  def new_user?
    if !@hash[:user][:email] || @last_user != @hash[:user][:email]
      @last_user = @hash[:user][:email]
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
    if new_listing? && @hash[:listing][:external_id].present?
      add_object(Transactable, @listing_builder, klass_symbol: :listing) do
        @listing_builder.action_type do |action|
          @action_type_builder = Nokogiri::XML::Builder.new({}, action.parent)
        end
        @listing_builder.photos do |photos|
          @photo_builder = Nokogiri::XML::Builder.new({}, photos.parent)
        end
        @listing_builder.availability_rules do |availabilities|
          @availability_builder = Nokogiri::XML::Builder.new({}, availabilities.parent)
        end
      end
    end
    yield if @hash[:listing][:external_id].present?
  end

  def build_photos
    add_object(Photo, @photo_builder) if @hash[:photo].any? { |_k, v| v.present? }
  end
end
