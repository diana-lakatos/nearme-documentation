class DataImporter::XmlFile < DataImporter::File
  attr_accessor :trackers

  def initialize(path, transactable_type, options = {})
    super(path)
    @transactable_type = transactable_type
    @users_emails = []
    @new_users_emails = {}
    @location_types = {}
    @synchronizer = options.fetch(:synchronizer, DataImporter::NullSynchronizer.new)
    @inviter = options.fetch(:inviter, DataImporter::NullInviter.new)
    @enable_rfq = options.fetch(:enable_rfq, false)
    @trackers = options.fetch(:trackers, [])
  end

  def parse
    @node = Nokogiri::XML(open(@path))
    @time_started = Time.zone.now
    parse_instance do
      parse_companies do
        parse_locations do
          parse_availabilities
          parse_listings do
            parse_action do
              parse_availabilities
            end
            parse_photos
          end
        end
      end
    end
    @inviter.send_invitation_emails(@new_users_emails)
  end

  def parse_instance
    @node.xpath('companies').each do |instance_node|
      @node = instance_node

      yield
    end
  end

  def parse_companies
    @node.xpath('company').each do |company_node|
      external_id = company_node['id']
      @company = Company.find_by(external_id: external_id)
      unless @company.present?
        @company = Company.new do |c|
          assign_attributes(c, company_node)
          c.external_id = external_id
          c.completed_at = Time.zone.now
        end
      end

      @synchronizer.company = @company
      @synchronizer.mark_all_object_to_delete!
      trigger_event('object_created', @company)
      if !@company.changed? || @company.save

        parse_users(company_node)
        if @company.creator.present?
          @node = company_node

          yield

          trigger_event('parsing_finished',             'location' => @synchronizer.delete_active_record_relation!(@company.locations),
                                                        'listing' => @synchronizer.delete_active_record_relation!(@company.listings),
                                                        'photo' => @synchronizer.delete_active_record_relation!(@company.photos))
        else
          trigger_event('custom_validation_error', "Company #{@company.external_id} has no valid user, skipping")
          @company.destroy
        end
      else
        trigger_event('object_not_saved', @company, @company.external_id)
      end
    end
  end

  def parse_users(company_node)
    company_node.xpath('users//user').each do |user_node|
      email = value_of('email', user_node).tap(&:downcase!)
      name = value_of('name', user_node)

      next unless email.present?
      @user = User.find_by(email: email)
      if @user.nil?
        @user = User.new do |u|
          password = SecureRandom.hex(8)
          u.email = email
          u.password = password
          u.name = name
          u.country_name = 'United States'
          u.instance_id = PlatformContext.current.instance.id
          @new_users_emails[email] = password
        end
      end

      if @user.persisted? || @user.valid?
        unless @users_emails.include?(email)
          trigger_event('object_valid', @user, @user.email)
          @users_emails << email
        end

        @user.save!(validate: false)

        if @company.creator.nil?
          @company.creator_id = @user.id
          @company.save(validate: false)
        end

        @company.users << @user unless @company.company_users.pluck(:user_id).include?(@user.id)
      else
        trigger_event('object_not_valid', @user, @user.email)
        @new_users_emails.delete(email)
      end
    end
  end

  def parse_locations
    @node.xpath('locations/location').each do |location_node|
      @photo_updated = false
      external_id = location_node['id']
      @location = Location.with_deleted.where(company_id: @company.id, external_id: external_id, instance_id: PlatformContext.current.instance.id).first || @company.locations.build
      assign_attributes(@location, location_node)
      @location = @synchronizer.unmark_object(@location)
      @location.location_type = find_location_type(value_of('location_type', location_node))
      @node = location_node
      @object = @location
      if @location.deleted?
        Location.transaction do
          @location.update_column(:deleted_at, nil)
          ApprovalRequest.with_deleted.where(owner: @location).update_all(deleted_at: nil)
          Impression.with_deleted.where(impressionable: @location).update_all(deleted_at: nil)
        end
      end

      # We do this here because assigning / building a location address to a
      # location can make it invalid and we need to know in advance not think it's
      # valid and then end up with it actually being invalid
      location_node.xpath('location_address').each do |address_node|
        @address = @location.location_address || @location.build_location_address
        assign_attributes(@address, address_node)
        @address.formatted_address = [@address.read_attribute(:address), @address.suburb, @address.city, @address.postcode].compact.join(', ')
      end

      if @location.valid?
        trigger_event('object_valid', @location)

        yield

        @address.save if @address.changed? && !@location.changed? && @location.valid? && !@location.new_record?

        if @location.changed?
          if @location.save
            @location.populate_photos_metadata! if @photo_updated
          else
            trigger_event('object_not_saved', @location, @location.external_id)
            @synchronizer.unmark_object!(@location)
          end
        else
          @synchronizer.unmark_object!(@location)
        end
      else
        @synchronizer.unmark_object!(@location)
        trigger_event('object_not_valid', @location, @location.external_id)
      end
    end
  end

  def parse_listings
    @node.xpath('listings/listing').each do |listing_node|
      @listing_photo_updated = false
      external_id = listing_node['id']
      @listing = Transactable.with_deleted.where(location: @location, external_id: external_id, instance_id: PlatformContext.current.instance.id).first || @location.listings.build(transactable_type: @transactable_type, external_id: external_id)
      assign_attributes(@listing, listing_node)
      @node = listing_node
      @object = @listing
      @listing.photo_not_required = true
      @listing.categories_not_required = true
      @listing = @synchronizer.unmark_object(@listing)
      if @listing.deleted?
        Transactable.transaction do
          @listing.update_column(:deleted_at, nil)
          AvailabilityRule.with_deleted.where(target: @listing).update_all(deleted_at: nil)
          ApprovalRequest.with_deleted.where(owner: @listing).update_all(deleted_at: nil)
          Impression.with_deleted.where(impressionable: @listing).update_all(deleted_at: nil)
        end
      end

      yield

      if @listing.valid?
        trigger_event('object_valid', @listing)
        @listing.action_rfq = @enable_rfq
        @listing.skip_metadata = true
        ApprovalRequestInitializer.new(@listing, @listing.try(:location).try(:company).try(:creator)).process unless @listing.is_trusted?
        @listing.save! if @listing.changed? || (@listing_photo_updated && @listing.new_record?)
        @listing.populate_photos_metadata! if @listing_photo_updated
        # We do this here, after the listing is saved and done because working on the categories association
        # forces the committing of the listing to the DB
        assign_listing_categories(listing_node, @listing)
      else
        trigger_event('object_not_valid', @listing, @listing.external_id)
        @synchronizer.unmark_object!(@listing)
      end
    end
  end

  def assign_listing_categories(listing_node, listing)
    categories = value_of('listing_categories', listing_node)
    if categories.present?
      # This will work always because @listing.categories_not_required was set earlier
      listing.categories = []
      categories.split(/\s*,\s*/).each do |category_permalink|
        category = Category.find_by(permalink: category_permalink)
        listing.categories << category if category.present?
      end
      listing.save
    end
  end

  def parse_availabilities
    @object.availability_rules.destroy_all if @node.xpath('availability_rules/availability_rule').any?
    @node.xpath('availability_rules/availability_rule').each do |availability_node|
      if @object.persisted?
        @object.availability_rules.create { |a| assign_attributes(a, availability_node) }
      else
        @object.availability_rules.build { |a| assign_attributes(a, availability_node) }
      end
    end
  end

  def parse_action
    return if value_of('action_type/type', @node).blank?
    @action_type = Transactable::ActionType.where(
      transactable: @listing,
      enabled: true,
      type: value_of('action_type/type', @node)
    ).first_or_initialize.becomes(value_of('action_type/type', @node).constantize)
    @object = @action_type

    yield

    @action_type.transactable_type_action_type ||= @transactable_type.action_types.where('type ilike ?', "%#{@action_type.type.demodulize}%").first
    @node.xpath('action_type/pricings/pricing').map do |pricing_attrs|
      pricing = @action_type.pricings.where(
        number_of_units: value_of('number_of_units', pricing_attrs),
        unit: value_of('unit', pricing_attrs)
      ).first_or_initialize
      pricing.price_cents = value_of('price_cents', pricing_attrs).to_i if value_of('price_cents', pricing_attrs).to_i > 0
      pricing.is_free_booking = false if value_of('price_cents', pricing_attrs).to_i > 0
      pricing.transactable_type_pricing ||= @action_type.transactable_type_action_type && @action_type.transactable_type_action_type.pricings.where(pricing.slice(:number_of_units, :unit)).first
      pricing.save if @listing.persisted?
    end
    @listing.action_type = @action_type
    @action_type.transactable = @listing
    @action_type.save if @listing.persisted?
  end

  def parse_photos
    if @synchronizer.performing_real_operations? # no need to store this in memory if no sync mode
      @photos_hash = @listing.photos.each_with_object({}) do |p, hash|
        hash[p.image_original_url] = p
        hash
      end
    end

    @node.xpath('photos/photo').each do |photo_node|
      if @listing.photos.map(&:image_original_url).include?(value_of('image_original_url', photo_node))
        trigger_event('object_not_created', 'photo')
        @synchronizer.unmark_object!(@photos_hash[value_of('image_original_url', photo_node)]) if @photos_hash.present?
      else
        if remote_file_exists?(value_of('image_original_url', photo_node))
          @photo_updated = true
          @listing_photo_updated = true
          if @listing.persisted?
            @photo = @listing.photos.create(image_original_url: value_of('image_original_url', photo_node), skip_metadata: true)
          else
            @photo = @listing.photos.build(image_original_url: value_of('image_original_url', photo_node), skip_metadata: true)
            # We do this because of a bug in Rails (possibly) whereby if the @photo object is saved as a consequence of the saving
            # of the parent association (i.e. @listing.save), @photo's previous_changes will be blank, thus not triggering the regeneration
            # of the versions in lib/carrier_wave/delayed_versions.rb
            @photo.force_regenerate_versions = true
          end
          trigger_event('object_created', @photo)
        else
          @photo = Photo.new(image_original_url: value_of('image_original_url', photo_node), skip_metadata: true)
          trigger_event('object_not_valid', @photo, @photo.image_original_url)
        end
      end
    end
  end

  private

  def trigger_event(event_name, *args)
    @trackers.each { |t| t.send(event_name, *args) }
  end

  def assign_attributes(object, node)
    xml_attributes = Transactable === object ? object.class.xml_attributes(@transactable_type) : object.class.xml_attributes
    object.attributes = xml_attributes.each_with_object({}) do |attribute, attributes|
      # Company's properties are something else entirely, we do not want to assign to that
      if object.respond_to?(:properties) && !object.respond_to?(attribute) && !object.is_a?(Company)
        attributes[:properties] ||= {}
        attributes[:properties][attribute] = value_of(attribute, node)
      elsif object.respond_to?(attribute)
        attributes[attribute] = value_of(attribute, node) unless :location_type == attribute.to_sym || value_of(attribute, node).blank?
      end
      attributes
    end
  end

  def find_location_type(name)
    if name.blank?
      @location_type_first ||= LocationType.first
    else
      lower_name = name.mb_chars.downcase
      @location_types[lower_name] ||= LocationType.where('lower(name) like ?', lower_name).first
      raise "Unknown LocationType #{name}, valid names: #{LocationType.pluck(:name)}" if @location_types[lower_name].nil?
      @location_types[lower_name]
    end
  end

  def value_of(attribute, node)
    node.xpath(attribute.to_s).text
  end

  def remote_file_exists?(photo_url)
    if photo_url =~ ActionView::Helpers::AssetUrlHelper::URI_REGEXP
      url = URI.parse(photo_url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https')

      http.start do |http|
        response = http.head(url.request_uri)
        return remote_file_exists?(response.header['Location']) if response.code == "301"
        return response.content_type.start_with? 'image'
      end
    else
      false
    end
  end
end
