module Utils
  class FakeDataSeeder

    class WrongEnvironmentError < StandardError; end
    class NotEmptyDatabaseError < StandardError; end

    module Data
      AMENITIES =
      {
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

      INDUSTRIES =
        [
          "Accounting", "Airlines/Aviation", "Alternative Dispute Resolution", "Alternative Medicine",
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
           "Wireless", "Writing and Editing"
        ]

      LOCATION_TYPES = ["Business", "Co-working", "Public"]

      LISTING_TYPES = ["Private office", "Meeting room", "Shared desks"]

    end

    def go!
      validate!
      load_data!
    end

    private

    def do_task(task_name = "")
      ActiveRecord::Migration.say_with_time(task_name) do
        yield
      end
    end

    def load_data!
      do_task "Loading data" do
        User.transaction do

          # ========================================= BASIC STUFF ====================================

          amenities = do_task "Loading amenities" do
            Data::AMENITIES.each_with_index.map do |(amenity_type_name, amenity_names), index|
              amenity_type = FactoryGirl.build(:amenity_type, :name => amenity_type_name, :position => index).tap do |resource|
                resource.save!
              end

              amenity_names.map do |amenity_name|
                FactoryGirl.build(:amenity, :name => amenity_name, :amenity_type => amenity_type).tap do |resource|
                  resource.save!
                end
              end
            end.flatten
          end

          industries = do_task "Loading industries" do
            Data::INDUSTRIES.map do |name|
              FactoryGirl.build(:industry, :name => name).tap do |resource|
                resource.save!
              end
            end
          end

          location_types = do_task "Loading location types" do
            Data::LOCATION_TYPES.map do |name|
              FactoryGirl.build(:location_type, :name => name).tap do |resource|
                resource.save!
              end
            end
          end

          listing_types = do_task "Loading listing types" do
            Data::LISTING_TYPES.map do |name|
              FactoryGirl.build(:listing_type, :name => name).tap do |resource|
                resource.save!
              end
            end
          end

          # ======================================= INSTANCES / PARTNERS ===================================

          partners = do_task "Loading partners" do
            ["Mega desks", "Super desks", "Cool desks"].map do |name|
              FactoryGirl.build(:partner, :name => name).tap do |resource|
                resource.save!
              end
            end
          end

          instances = do_task "Loading instances" do
            ["DesksNearMe"].map do |name|
              FactoryGirl.build(:instance, :name => name).tap do |resource|
                resource.save!
              end
            end
          end

          # ================================= COMPANIES / LOCATIONS / LISTINGS ============================

          # populator, snapshot?, extract methods # TODO

          users = []
          companies = do_task "Loading companies" do
            (30.times.map { Faker::Internet.domain_name } + ["desksnear.me"]).map do |url|
              instance = instances.sample # TODO temp
              company_email = "#info@#{url}"
              creator = FactoryGirl.build(:user, :name => Faker::Name.name, :email => company_email,
                                          :instance => instance, :industries => industries.sample(2)).tap do |resource|
                resource.save!
              end
              users << creator

              FactoryGirl.build(:company, :name => url, :email => company_email, :url => url,
                                :instance => instance, :creator => creator, :industries => creator.industries).tap do |resource|
                resource.save!
              end
            end
          end

          locations = do_task "Loading locations" do
            CSV.foreach(Rails.root.join(*%w(db seeds addresses.csv)), :headers => :first_row, :return_headers => false).map do |row|
              address, lat, lng = row[0], row[1], row[2]
              company = companies.sample

              location = FactoryGirl.build(:location, :amenities => amenities.sample(2), :location_type => location_types.sample,
                                           :company => company, :email => company.email, :address => address,
                                           :latitude => lat, :longitude => lng).tap do |resource|
                resource.save!
              end

              listing_types.sample(2).each do |listing_type|
                name = listing_type.name # TODO
                FactoryGirl.build(:listing, :listing_type => listing_type, :name => name, :location => location).tap do |resource|
                  resource.save!
                end
              end
              location
            end
          end

          # =================================================================================================

        end
      end

    end

    def not_empty_database?
      do_task "Checking database" do
        # too bad we can't use this (due to records that are ):
        # Rails.application.eager_load!
        # ActiveRecord::Base.descendants.any? &:any?
        [Location, User, Company, Partner, Instance].any? &:any?
      end
    end

    def validate!
      do_task "Validating" do
        raise WrongEnvironmentError if wrong_env?
        raise NotEmptyDatabaseError if not_empty_database?
      end
    end

    def wrong_env?
      do_task "Checking environment" do
        Rails.env.production?
      end
    end

  end
end
