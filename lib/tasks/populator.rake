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
   
    begin
      locations = Location.all.select{|location| location.address_components.blank? }
      locations.each do |location|
        Location::AddressComponentsPopulator.new(location, use_limit: true, show_inspections: true).perform
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
        listing = Listing.find_by_id(listing_id)
        if listing
          puts "#{listing.id} > #{index+1}"
          listing.update_attribute(:rank, index+1)
        end
      end
    end
  end

end
