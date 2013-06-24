class DataImporter::XmlFile < DataImporter::File

  def initialize(path)
    super(path)
  end

  def default_industries
    @default_industries ||= [Industry.find_by_name('Commercial Real Estate')]
  end

  def default_location_type
    @default_location_type ||= LocationType.find_by_name('Business')
  end

  def listing_type_for_name(listing_name)
    if listing_name.downcase.include?('office')
      @listing_type_for_office ||= ListingType.find_by_name('Office Space')
    else 
      @listing_type_for_meeting_room ||= ListingType.find_by_name('Meeting Room')
    end
  end

  def parse
    @node = Nokogiri::XML(open(@path))
    DROPBOX.connect
    parse_instance do
      parse_companies do
        parse_locations do
          parse_availabilities
          parse_amenities
          parse_listings do
            parse_availabilities
          end
        end
        download_photos_from_dropbox
      end
    end
  end

  def parse_instance
    @node.xpath('companies').each do |instance_node|
      tenant_name = instance_node['tenant']
      @instance = Instance.find_by_name(tenant_name) || Instance.create(:name => tenant_name)
      @node = instance_node
      yield
    end
  end

  def parse_companies
    @node.xpath('company').each do |company_node|
      external_id = company_node['id']
      email = company_node.xpath('email').text.downcase
      name = company_node.xpath('name').text
      @user = @instance.users.find_by_email(email) || @instance.users.create do |u|
        password =  SecureRandom.hex
        open('/tmp/passwords.txt', 'a') { |f|
          f.puts "#{email}:#{password}"
        }
        u.email = email
        u.password = password
        u.name = name
        u.country_name = 'United States'
      end
      @company = @user.companies.find_by_external_id(external_id) || @user.companies.create do |c|
        assign_attributes(c, company_node)
        c.external_id = external_id
        c.industries = default_industries
        c.instance = @instance
      end
      @node = company_node
      yield
    end
  end

  def parse_locations
    @node.xpath('locations/location').each do |location_node|
      @user.update_attribute(:phone, location_node.xpath('phone').text) if @user.phone.blank?
      @location = @company.locations.find_by_address(location_node.xpath('address').text) || @company.locations.build do |l|
        l.location_type = default_location_type
      end
      assign_attributes(@location, location_node)
      @location.formatted_address = @location.address
      @node = location_node
      @object = @location
      yield
      @location.save!
    end
  end

  def parse_listings
    @node.xpath('listings/listing').each do |listing_node|
      external_id = listing_node['id']
      @listing = @location.listings.find_by_external_id(external_id) || @location.listings.build do |l|
        l.external_id = external_id
      end
      assign_attributes(@listing, listing_node)
      @listing.listing_type = listing_type_for_name(@listing.name)
      @listing.confirm_reservations = true
      @listing.hourly_reservations = true
      @node = listing_node
      @object = @listing
      yield
      if @location.persisted?
        @listing.save!
        @listing.photos.each { |p| p.save! }
      end
    end
  end

  def parse_availabilities
    @object.availability_rules.destroy_all
    @node.xpath('availability_rules/availability_rule').each do |availability_node|
      @object.availability_rules.build { |a| assign_attributes(a, availability_node) }
    end
  end

  def parse_amenities
    @object.amenities.destroy_all
    @node.xpath('amenities/amenity').each do |amenity_node| 
      @object.amenities << Amenity.find_by_name(amenity_node.xpath('name').text) 
    end
  end

  def download_photos_from_dropbox
    # get all images for given company that are in dropbox, find photo that best matches object.name and download it
    files_with_info = DROPBOX.get_files_for_path(File.join("PBCenter", @company.external_id)).inject({}) do |files, file|
      if file.mime_type.try(:include?, 'image')
        file_name = File.basename(file.path)
        files[file_name] = {:remote_image_url => file.direct_url.url, :content_type => file.mime_type}
      end
      files
    end
    if !files_with_info.empty?
      listings = @company.locations.map { |l| l.listings }.flatten.reject { |listing| listing.photos.count > 0 }
      listing_name_file_name_pairs = StringMatcher.new(listings.map(&:name), files_with_info.keys).create_pairs
      listings.each do |listing|
        if listing_name_file_name_pairs[listing.name]
          listing_name_file_name_pairs.delete(listing.name).each do |matching_photo_name|
            listing.photos.create do |p|
              direct_url = files_with_info[matching_photo_name]
              p.remote_image_url = direct_url[:remote_image_url]
              p.content_type = direct_url[:content_type]
            end
          end
        end
      end
    end
  end

  private

  def assign_attributes(object, node)
    object.attributes = object.class.xml_attributes.inject({}) do |attributes, attribute| 
      attributes[attribute] = node.xpath(attribute.to_s).text
      attributes
    end
  end

end

