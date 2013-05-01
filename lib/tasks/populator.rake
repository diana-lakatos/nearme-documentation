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
    amenities_hash = {
      'Food' => [
        'Coffee/Tea', 'Espresso', 'Fridge',
        'Kitchen', 'Microwave', 'Refreshments',
        'Vending Machine'
      ],

      'Access' => [
        '24/7 Access', 'Eateries Nearby', 'Elevator Access',
        'Handicap Access', 'Parking', 'Street Parking',
        'Transport Nearby'
      ],

      'Rooms' => [
        'Conference Room', 'Lounge Area', 'Lunch Room',
        'Meeting Rooms', 'Multi-purpose Room', 'Shower Room',
        'Yard Area'
      ],

      'Facilities' => [
        'Administrative Assistant', 'Copier', 'Fax',
        'Internet Access', 'IT Support', 'Mail Service',
        'Monitors', 'Printer', 'Projector',
        'Receptionist', 'Scanner', 'Telephone',
        'Videoconferencing Facilities', 'Whiteboard'
      ],

      'Entertainment' => [
        'Games',
        'Gym',
        'Happy Hour',
        'Ping Pong Table',
        'Recreational Facilities',
        'Television'
      ],

      'Kids & Pets' => [
        'Child Friendly',
        'Childrens Playroom',
        'Pet Friendly'
      ]
    }

    i = 0
    amenities_hash.each do |amenity_type_name, amenities_array|
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
    populator = Location::AddressComponentsPopulator.new
    begin
      Location.find_each do |l|
        populator.populate(l)
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

    ["Accounting", "Airlines/Aviation", "Alternative Dispute Resolution", "Alternative Medicine",
     "Animation", "Apparel & Fashion", "Architecture & Planning", "Arts and Crafts", "Automotive",
     "Aviation & Aerospace", "Banking", "Biotechnology", "Broadcast Media", "Building Materials",
     "Business Supplies and Equipment", "Capital Markets", "Chemicals", "Civic & Social Organization",
     "Civil Engineering", "Commercial Real Estate", "Computer & Network Security", "Computer Games",
     "Computer Hardware", "Computer Networking", "Computer Software", "Construction", "Consumer Electronics",
     "Consumer Goods", "Consumer Services", "Cosmetics", "Dairy", "Defense & Space", "Design",
     "Education Management", "E-Learning", "Electrical/Electronic Manufacturing", "Entertainment",
     "Environmental Services", "Events Services", "Executive Office", "Facilities Services",
     "Farming", "Financial Services", "Fine Art", "Fishery", "Food & Beverages", "Food Production",
     "Fund-Raising", "Furniture", "Gambling & Casinos", "Glass, Ceramics & Concrete",
     "Government Administration", "Government Relations", "Graphic Design", "Health, Wellness and Fitness",
     "Higher Education", "Hospital & Health Care", "Hospitality", "Human Resources", "Import and Export",
     "Individual & Family Services", "Industrial Automation", "Information Services", "Information Technology and Services",
     "Insurance", "International Affairs", "International Trade and Development", "Internet", "Investment Banking",
     "Investment Management", "Judiciary", "Law Enforcement", "Law Practice", "Legal Services", "Legislative Office",
     "Leisure, Travel & Tourism", "Libraries", "Logistics and Supply Chain", "Luxury Goods & Jewelry", "Machinery",
     "Management Consulting", "Maritime", "Marketing and Advertising", "Market Research", "Mechanical or Industrial Engineering",
     "Media Production", "Medical Devices", "Medical Practice", "Mental Health Care", "Military",
     "Mining & Metals", "Motion Pictures and Film", "Museums and Institutions", "Music", "Nanotechnology",
     "Newspapers", "Nonprofit Organization Management", "Oil & Energy", "Online Media", "Outsourcing/Offshoring",
     "Package/Freight Delivery", "Packaging and Containers", "Paper & Forest Products", "Performing Arts",
     "Pharmaceuticals", "Philanthropy", "Photography", "Plastics", "Political Organization", "Primary/Secondary Education",
     "Printing", "Professional Training & Coaching", "Program Development", "Public Policy",
     "Public Relations and Communications", "Public Safety", "Publishing", "Railroad Manufacture", "Ranching",
     "Real Estate", "Recreational Facilities and Services", "Religious Institutions", "Renewables & Environment",
     "Research", "Restaurants", "Retail", "Security and Investigations", "Semiconductors", "Shipbuilding",
     "Sporting Goods", "Sports", "Staffing and Recruiting", "Supermarkets", "Telecommunications", "Textiles",
     "Think Tanks", "Tobacco", "Translation and Localization", "Transportation/Trucking/Railroad", "Utilities",
     "Venture Capital & Private Equity", "Veterinary", "Warehousing", "Wholesale", "Wine and Spirits",
     "Wireless", "Writing and Editing"].each do |name|
        Industry.create(:name => name) 
      end
  end

end
