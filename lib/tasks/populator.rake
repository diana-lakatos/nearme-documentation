namespace :populate do
  desc "Populates unit prices"
  task :prices => :environment do
    {"daily_price_cents" => 1440, "weekly_price_cents" => 10080, "monthly_price_cents" => 43200}.each do |column, period|
      ActiveRecord::Base.connection.execute("
          UPDATE listings AS l
          SET #{column} = up.price_cents
          FROM unit_prices AS up
          WHERE l.id = up.listing_id
            AND up.period = #{period}
            AND (
              l.#{column} IS NULL
              OR l.#{column} = 0
            )

                                            ")
    end
  end

  desc 'populates metadata, foreign_keys and other redundant info for objects'
  task :redundant_data => :environment do
    User.with_deleted.find_each do |user|
      user.populate_companies_metadata!
      user.populate_instance_admins_metadata!
    end
    Company.with_deleted.find_each(&:populate_industries_metadata!)
    Location.with_deleted.find_each do |location|
      location.update_column(:listings_public, location.company.listings_public)
      creator_id = location.company.creator_id
      instance_id = location.company.instance_id
      administrator_id = (location.administrator_id == creator_id ? nil : location.administrator_id)

      location.creator_id = creator_id
      location.instance_id = instance_id
      location.save(validate: false)

      location.listings.with_deleted.each do |listing|
        listing.creator_id = creator_id
        listing.instance_id = instance_id
        listing.administrator_id = administrator_id if administrator_id.present?

        listing.reservations.with_deleted.each do |reservation|
          reservation.creator_id = creator_id
          reservation.instance_id = instance_id
          reservation.administrator_id = administrator_id if administrator_id.present?
          reservation.save(validate: false)
        end
        listing.save(validate: false)
        listing.populate_photos_metadata!
        listing.populate_listing_type_name_metadata!
      end
    end
  end

  desc 'populates platform_context_details for reservations'
  task :reservation_platform_context_detail => :environment do
    Reservation.where('platform_context_detail_id is null').each do |r|
      if r.listing.present?
        if r.listing.company && r.listing.company.white_label_enabled
          puts "#{r.id} is assigned to white label company"
          r.platform_context_detail = r.listing.company
          r.save(:validate => false)
        else
          puts "#{r.id} is assigned to instance"
          r.platform_context_detail = r.listing.instance
          r.save(:validate => false)
        end
      else
        puts "Warning, #{r.id} does not belong to any listing!"
      end
    end
  end

  desc "Populates missing amenities and ensures they belong to the right amenity type"
  task :amenities => :environment do
    i = 0
    Utils::FakeDataSeeder::Data.amenities.each do |amenity_type_name, amenities_array|
      amenity_type = AmenityType.where(:name => amenity_type_name).first_or_create
      amenity_type.position = i
      amenity_type.save!
      puts "Created amenity type: #{amenity_type.name}, position #{i}"
      amenities_array.each do |amenity_name|
        amenity = Amenity.where(:name => amenity_name).first_or_create
        amenity.amenity_type = amenity_type
        amenity.save!
        puts amenity.name
      end
      i += 1
      puts "----"
    end

  end

  desc "Populates locations with address components"
  task :locations => :environment do
    limit = 500
    current_geocoding = 0

    begin
      locations = Location.all.select{|location| location.address_components.blank? }
      locations.each do |location|
        current_geocoding += 1
        raise 'Limit reached' if current_geocoding > limit
        Address::AddressComponentsPopulator.new(location, show_inspections: true).perform
      end
      puts "Done."
    rescue
      puts "Populator failed: #{$!.inspect}"
    end
  end

  desc "Populates industries"
  task :industries! => :environment do
    Industry.delete_all
    CompanyIndustry.delete_all

    Utils::FakeDataSeeder::Data.industries.each do |name|
      Industry.create(:name => name)
    end
  end

  desc "Populates top results in top cities"
  task :top_cities => :environment do
    Utils::FakeDataSeeder::Data.top_cities.each do |city_name, city|
      city.reverse.each_with_index do |listing_id, index|
        listing = Transactablefind_by_id(listing_id)
        if listing
          puts "#{listing.id} > #{index+1}"
          listing.update_attribute(:rank, index+1)
        end
      end
    end
  end

  desc "Populates users with info from authentications"
  task :social_info => :environment do
    Authentication.find_each do |authentication|
      begin
        updater = Authentication::InfoUpdater.new(authentication).update
        puts "Authentication #{authentication.id}: updated with #{updater.authentication_changes.inspect}"
        puts "User #{authentication.user_id}: updated with #{updater.user_changes.inspect}"
      rescue Authentication::InvalidToken
        authentication.expire_token! if authentication.token_expires?
        puts "Authentication #{authentication.id}: InvalidToken"
      rescue => e
        puts "Authentication #{authentication.id}: #{e}"
      end
    end
  end

  desc "Populates en locales"
  task :en_locales => :environment do
    Utils::EnLocalesSeeder.new.go!
  end

  desc "Populate instance views"
  task :instance_views => :environment do
    Utils::InstanceViewsSeeder.new.go!
  end

  desc "Populate transactable"
  task :transactables => :environment do
    Listing.find_each do |listing|
      puts "Creating Transactable #{listing.id}"
      next if listing.location.blank?
      t = Transactable.new
      listing.attributes.each do |attr, value|
        next if attr == "photos_count"
        t.send("#{attr}=", value)
      end
      t.save(validate: false)
    end
    ActiveRecord::Base.connection.reset_pk_sequence!(:transactables)
  end

  desc "Populate transactable types"
  task :transactable_types => :environment do
    TransactableType.destroy_all
    Instance.find_each do |instance|
      PlatformContext.current = PlatformContext.new(instance)
      PlatformContext.scope_to_instance
      tp = TransactableType.find_or_create_by_name("Listing")
      Utils::TransactableTypeAttributesCreator.new(tp).create_listing_attributes!
      Transactable.update_all(:transactable_type_id => tp.id)
      Transactable.find_each do |t|
        begin
          t.listing_type = ListingType.find(t.listing_type_id).name
        rescue
          puts "Unable to find ListingType with id #{t.listing_type_id}"
        end
        t.name = t.read_attribute(:name)
        t.description = t.read_attribute(:description)
        t.save(validate: false)
      end
    end
  end

  desc "Populate transactable"
  task :millions_transactables => :environment do
    head_sql = "INSERT INTO transactables (activated_at, administrator_id, company_id, created_at, creator_id, deleted_at, description, draft, enabled, instance_id, instance_type_id, listing_type_id, listings_public, location_id, metadata, name, partner_id, properties, updated_at) VALUES "
    colors = ["red", "green", "blue"]
    1000.times do |i|
      Transactable.transaction do
        values = []
        1000.times do |j|
          values << %Q((NULL, NULL,143, now(), 246, NULL, 'jkl', NULL, false, 1, NULL, 2, true, 261, NULL, 'jkljkl', NULL, '"quantity"=>"#{Random.rand(20)}","capacity"=>"#{Random.rand(20)}","free"=>"false","hourly_reservations"=>"false","weekly_price_cents"=>"6700","color" => "#{colors[Random.rand(3)]}", "confirm_reservations"=>"0", "delta"=>"true", "rank"=>"#{Random.rand(20)}"', now()))
        end
        Transactable.connection.execute head_sql + values.join(", ")
        puts "added #{(i+1)}"
      end
    end
  end

  desc 'Populate user metadata based on PlatformContext'
  task :user_metadata => :environment do
    User.find_each do |user|
      if user.metadata.empty?
        puts "skipping #{user.id}"
      else
        Instance.find_each do |i|
          PlatformContext.current = PlatformContext.new(i)
          puts i.name
          user.populate_companies_metadata!
          user.populate_instance_admins_metadata!
          user.populate_listings_metadata!
        end
        puts "finished user: #{user.id}"
      end
    end
  end

end
