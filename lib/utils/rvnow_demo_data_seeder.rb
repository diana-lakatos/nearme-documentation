require 'timecop'

module Utils
  class RvnowDemoDataSeeder < Utils::DemoDataSeeder

    Data.class_eval do
      def self.load_demo_yaml(collection)
        YAML.load_file(Rails.root.join('db', 'seeds', 'demo', 'rvnow', collection))
      end

      def self.location_types
        @location_types ||= load_demo_yaml("location_types.yml")
      end

      def self.load_page_content(filename)
        File.open(Rails.root.join('db', 'seeds', 'demo', 'rvnow', filename), 'r') { |f| f.read }
      end
    end

    protected

    def load_data!
      do_task "Loading data" do
        User.transaction do 

          # === INSTANCES / PAGES ================================

          load_instance!
          load_pages!

          # === BASIC STUFF ======================================

          load_amenities!
          load_industries!
          load_location_types!
          load_listing_types!

          # === COMPANIES / LOCATIONS / LISTINGS =================

          load_users_and_companies!
          make_user_an_instance_admin!
          load_locations_with_listings!

          puts "\e[32mUser created with email: #{@user.email} and password: #{@user.password}\e[0m"
        end
      end
    end

    def load_amenities!
      @amenities ||= do_task "Loading amenities" do
        Data.amenities.each_with_index.map do |(amenity_type_name, amenity_names), index|
          amenity_type = FactoryGirl.create(:amenity_type, :name => amenity_type_name, :position => index, :type => 'LocationAmenityType', :instance_id => instance.id)

          amenity_names.map do |amenity_name|
            FactoryGirl.create(:amenity, :name => amenity_name, :amenity_type => amenity_type)
          end
        end.flatten
      end
    end
    alias_method :amenities, :load_amenities!

    def load_location_types!
      @location_types ||= do_task "Loading location types" do
        Data.location_types.map do |name|
          FactoryGirl.create(:location_type, name: name, instance: instance)
        end
      end
    end
    alias_method :location_types, :load_location_types!

    def load_listing_types!
      @listing_types ||= do_task "Loading listing types" do
        Data.listing_types.map do |name|
          FactoryGirl.create(:listing_type, name: name, instance: instance)
        end
      end
    end
    alias_method :listing_types, :load_listing_types!

    def load_instance!
      @instance ||= do_task "Loading RVnow instance" do
        instance = FactoryGirl.create(:instance, name: 'RVnow', bookable_noun: 'RV', lessor: 'owner', lessee: 'renter', service_fee_guest_percent: 0, service_fee_host_percent: 0)
        theme = instance.theme
        theme.name = 'RVnow'
        theme.site_name = 'RVnow'
        theme.homepage_css = Data.load_page_content('homepage.css')
        theme.homepage_content = Data.load_page_content('homepage.txt')
        theme.tagline = 'Rent from trustworthy people all over America'
        theme.call_to_action = 'Find out more'
        theme.logo_image = File.open(Rails.root.join('db', 'seeds', 'demo', 'rvnow', 'brand_assets', 'RVnow.png'), 'rb')        
        theme.logo_retina_image = File.open(Rails.root.join('db', 'seeds', 'demo', 'rvnow', 'brand_assets', 'RVnow_retina.png'), 'rb')        
        theme.hero_image = File.open(Rails.root.join('db', 'seeds', 'demo', 'rvnow', 'brand_assets', 'RVnow_hero.jpg'), 'rb')        
        theme.color_black = 'F2B42E'
        theme.color_green = 'F2B42E'
        theme.color_blue = 'DB8B00'
        theme.save!

        theme.skip_compilation = false
        theme.recompile_theme

        instance
      end
    end
    alias_method :instance, :load_instance!

    def load_pages!
      @pages ||= do_task "Loading RVnow theme pages" do
        pages = []
        Dir.glob(Rails.root.join('db', 'seeds', 'demo', 'rvnow', 'pages', '*.txt')).each do |page_filename|
          page_content = File.open(page_filename, 'r') { |f| f.read }
          page_content_splited = page_content.split(/\n/) 
          page = Page.new(path: page_content_splited.first, content: page_content_splited[1..-1].join)
          page.theme = instance.theme
          page.save!

          pages << page
        end

        pages
      end
    end
    alias_method :pages, :load_pages!

    def make_user_an_instance_admin!
      administrator = InstanceAdminRole.new
      administrator.name = 'Administrator'
      administrator.instance_id = nil
      administrator.permission_settings = true
      administrator.permission_theme = true
      administrator.permission_transfers = true
      administrator.permission_inventories = true
      administrator.permission_partners = true
      administrator.permission_users = true
      administrator.permission_pages = true
      administrator.save!

      InstanceAdmin.create(user_id: @user.id, instance_admin_role_id: administrator.id, instance_id: instance.id)
    end

    def load_locations_with_listings!
      @locations_with_listing ||= do_task "Loading locations and listings" do
        locations, listings = [], []
        CSV.parse(File.open(Rails.root.join('db', 'seeds', 'demo', 'rvnow', 'listings.csv')).read, headers: true).each do |row|
          # LOCATION
          location = locations.select{|l| l.name == row['location_name']}.first

          if !location
            location = Location.new({
              company_id: companies.first.id,
              name: row['location_name'],
              address: row['address'],
              currency: 'USD',
              description: row['location_description'],
              email: @user.email,
              location_type_id: location_types.first{|lt| lt.name == row['location_type']}.id
            })

            location.amenities = amenities
            
            location.save!
            locations << location
          end

          # LISTING
          listing = Listing.new({
            location_id: location.id,
            name: row['listing_title'],
            listing_type_id: listing_types.first{|lt| lt.name == row['listing_type']}.id,
            quantity: 1,
            description: row['listing_description'],
            daily_price_cents: row['daily_price'],
            weekly_price_cents: row['weekly_price'],
            monthly_price_cents: row['monthly_price'],
            hourly_reservations: false
          })

          Dir.glob(Rails.root.join('db', 'seeds', 'demo', 'rvnow', 'listing_photos', row['folder_referrence'], '*')).each do |photo_filename|
            next if photo_filename == '.' || photo_filename == '..'
            photo = Photo.new(image: File.open(photo_filename, 'rb'))
            photo.save!

            listing.photos << photo
          end
          listing.save!

          listings << listing
        end

        [locations, listings]
      end
    end

  end
end

