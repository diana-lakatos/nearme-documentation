class DataImporter::XmlFile < DataImporter::File

  def initialize(path, transactable_type = nil, logger = nil, tracker = nil)
    super(path)
    @instance = PlatformContext.current.instance
    @transactable_type = transactable_type || @instance.transactable_types.first
    @users_emails = []
    @new_users_emails = {}
    @location_types = {}
    @logger = logger || DataImporter::Logger.new
    @tracker = tracker || DataImporter::SummaryTracker.new
  end

  def get_parse_result
    @logger.to_s
  end

  def get_summary
    {
     new: @tracker.new_entities,
     updated: @tracker.updated_entities
    }
  end

  def listing_type_for_name(listing_name)
    if listing_name.downcase.include?('office')
      'Private Office'
    else
      'Meeting Room'
    end
  end

  def parse
    @node = Nokogiri::XML(open(@path))
    parse_instance do
      parse_companies do
        parse_locations do
          parse_address
          parse_availabilities
          parse_amenities
          parse_listings do
            parse_availabilities
            parse_photos
          end
        end
      end
    end
    send_invitation_emails if @send_invitations
  end

  def parse_instance
    @node.xpath('companies').each do |instance_node|
      @send_invitations = instance_node['send_invitation'] == 'true' ? true : false
      @node = instance_node
      yield
    end
  end

  def parse_companies
    @node.xpath('company').each do |company_node|
      external_id = company_node['id']
      email = company_node.xpath('email').text.downcase
      name = company_node.xpath('name').text
      @company = Company.find_by_external_id(external_id)
      if !@company
        @company = Company.new do |c|
          assign_attributes(c, company_node)
          c.external_id = external_id
        end
      end
      @tracker.increment(@company)
      if @company.save
        company_node.xpath('users//user').each do |user_node|
          email = user_node.xpath('email').text.downcase
          name = user_node.xpath('name').text
          @user = @instance.users.find_by_email(email)
          if @user.nil?
            @user = @company.users.build do |u|
              password =  SecureRandom.hex(8)
              u.email = email
              u.password = password
              u.name = name
              u.country_name = 'United States'
              u.instance_id = PlatformContext.current.instance.id
              @new_users_emails[email] = password
            end
          end
          @tracker.increment(@user) unless @users_emails.include?(@user.email)
          @users_emails << email
          if @user.save
            @company.creator_id = @user.id if @company.creator.nil?
            @company.users << @user unless @company.users.include?(@user)
            @company.save!
          else
            @tracker.decrement(@user) unless @user.persisted? && @users_emails.include?(@user.email)
            @new_users_emails.delete(email)
            @logger.log_validation_error(@user, @user.email)
          end
        end
        if @company.creator.present?
          @node = company_node
          yield
        else
          @logger.log("Company #{@company.external_id} has no valid user, skipping")
          @company.destroy
        end
      else
        @tracker.decrement(@company)
        @logger.log_validation_error(@company, @company.external_id)
      end
    end
  end

  def parse_locations
    @node.xpath('locations/location').each do |location_node|
      @address = @company.locations.joins(:location_address).where('addresses.address = ? AND addresses.entity_type = ?', location_node.xpath('location_address/address').text, 'Location').select('addresses.entity_id').first
      @location = @address.present? ? Location.find(@address.entity_id) : @company.locations.build
      assign_attributes(@location, location_node)
      @location.location_type = find_location_type(location_node.xpath('location_type').text)
      @node = location_node
      @object = @location
      if @location.valid?
        @tracker.increment(@location)
        yield
        @location.save
      else
        @logger.log_validation_error(@location, @location.address)
      end
    end
  end

  def parse_address
    @node.xpath('location_address').each do |address_node|
      @address = @location.location_address || @location.build_location_address
      assign_attributes(@address, address_node)
      @address.formatted_address = [@address.address, @address.suburb, @address.city, @address.postcode].compact.join(', ')
      @tracker.increment(@address)
      if !@address.save
        @tracker.decrement(@address)
        @logger.log_validation_error(@address, @address.address)
      end
    end
  end

  def parse_listings
    @node.xpath('listings/listing').each do |listing_node|
      external_id = listing_node['id']
      @listing = @location.listings.find_by_external_id(external_id) || @location.listings.build(transactable_type: @transactable_type)
      @listing.external_id = external_id
      assign_attributes(@listing, listing_node)
      @node = listing_node
      @object = @listing
      @listing.photo_not_required = true
      if @listing.valid?
        @tracker.increment(@listing)
        yield
        @listing.save!
      else
        @logger.log_validation_error(@listing, @listing.external_id)
      end
    end
  end

  def parse_availabilities
    @object.availability_rules.destroy_all
    @node.xpath('availability_rules/availability_rule').each do |availability_node|
      @object.availability_rules.build { |a| assign_attributes(a, availability_node) }
    end
  end

  def parse_photos
    @node.xpath('photos/photo').each do |photo_node|
      if !@listing.photos.map(&:image_original_url).include?(photo_node.xpath('image_original_url').text)
        @photo = @listing.photos.build(image_original_url: photo_node.xpath('image_original_url').text)
        @tracker.increment(@photo)
      end
    end
  end

  def parse_amenities
    @object.amenities.destroy_all
    @node.xpath('amenities/amenity').each do |amenity_node|
      @object.amenities << Amenity.find_by_name(amenity_node.xpath('name').text)
    end
  end

  private

  def assign_attributes(object, node)
    object.attributes = object.class.xml_attributes.inject({}) do |attributes, attribute|
      attributes[attribute] = node.xpath(attribute.to_s).text unless :location_type == attribute.to_sym || node.xpath(attribute.to_s).text.blank?
      attributes
    end
  end

  def send_invitation_emails
    @new_users_emails.each do |email, password|
      PostActionMailer.enqueue.user_created_invitation(User.find_by_email(email), password)
    end
  end

  def find_location_type(name)
    if name.blank?
      @location_type_first ||= LocationType.first
    else
      @location_types[name] ||= LocationType.where(name: name).first
      raise "Unknown LocationType #{name}, valid names: #{LocationType.pluck(:name)}" if @location_types[name].nil?
      @location_types[name]
    end
  end

end

