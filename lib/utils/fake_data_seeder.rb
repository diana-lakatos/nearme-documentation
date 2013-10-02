module Utils
  class FakeDataSeeder

    class WrongEnvironmentError < StandardError; end
    class NotEmptyDatabaseError < StandardError; end

    module Data
      def self.amenities
        @amenities ||= load_yaml("amenities.yml")
      end

      def self.addresses
        @addresses ||= load_yaml("addresses.yml")
      end

      def self.industries
        @industries ||= load_yaml("industries.yml")
      end

      def self.location_types
        @location_types ||= load_yaml("location_types.yml")
      end

      def self.listing_types
        @listing_types ||= load_yaml("listing_types.yml")
      end

      def self.domains
        @domains ||= load_yaml("domains.yml")
      end

      def self.instances
        @instances ||= load_yaml("instances.yml")
      end

      private

        def self.load_yaml(collection)
          YAML.load_file(Rails.root.join('db', 'seeds', collection))
        end

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

          # === BASIC STUFF ======================================

          load_amenities!
          load_industries!
          load_location_types!
          load_listing_types!

          # === INSTANCES ========================================

          load_instances!

          # === COMPANIES / LOCATIONS / LISTINGS =================

          load_users_and_companies!
          load_locations!
          load_listings!

          # === RESERVERATIONS ===================================

          load_reservations_for_dnm!

          clean_up!
        end
      end

    end

    def not_empty_database?
      do_task "Checking database" do
        # too bad we can't use this (due to records that are ):
        # Rails.application.eager_load!
        # ActiveRecord::Base.descendants.any? &:any?
        [Location, User, Company, Instance].any? &:any?
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

    def load_amenities!
      @amenities ||= do_task "Loading amenities" do
        Data.amenities.each_with_index.map do |(amenity_type_name, amenity_names), index|
          amenity_type = FactoryGirl.create(:amenity_type, :name => amenity_type_name, :position => index)

          amenity_names.map do |amenity_name|
            FactoryGirl.create(:amenity, :name => amenity_name, :amenity_type => amenity_type)
          end
        end.flatten
      end
    end
    alias_method :amenities, :load_amenities!

    def load_industries!
      @industries ||= do_task "Loading industries" do
        Data.industries.map do |name|
          FactoryGirl.create(:industry, :name => name)
        end
      end
    end
    alias_method :industries, :load_industries!

    def load_location_types!
      @location_types ||= do_task "Loading location types" do
        Data.location_types.map do |name|
          FactoryGirl.create(:location_type, :name => name)
        end
      end
    end
    alias_method :location_types, :load_location_types!

    def load_listing_types!
      @listing_types ||= do_task "Loading listing types" do
        Data.listing_types.map do |name|
          FactoryGirl.create(:listing_type, :name => name)
        end
      end
    end
    alias_method :listing_types, :load_listing_types!

    def load_instances!
      @instances ||= do_task "Loading instances" do
        Data.instances.map do |name|
          FactoryGirl.create(:instance, :name => name)
        end
      end
    end
    alias_method :instances, :load_instances!

    def load_users_and_companies!
      @users_and_companies ||= do_task "Loading users and companies" do
        users, companies = [], []
        Data.domains.map do |url|
          company_email = "info@#{url}"
          user = FactoryGirl.create(:user, :name => Faker::Name.name, :email => company_email,
                                    :biography => Faker::Lorem.paragraph.truncate(200),
                                    :industries => industries.sample(2))
          users << user

          company = FactoryGirl.create(:company, :name => url, :email => user.email, :url => url,
                                          :description => Faker::Lorem.paragraph.truncate(200),
                                          :creator => user, :industries => user.industries)

          company.users << user

          companies << company
        end
        [users, companies]
      end
    end

    def users
      load_users_and_companies![0]
    end

    def companies
      load_users_and_companies![1]
    end

    def load_locations!
      @locations ||= do_task "Loading locations" do
        Data.addresses.map do |row|
          address, lat, lng = row[0], row[1], row[2]
          company = companies.sample

          FactoryGirl.create(:location, :amenities => amenities.sample(2), :location_type => location_types.sample,
                             :company => company, :email => company.email, :address => address,
                             :latitude => lat, :longitude => lng, :description => Faker::Lorem.paragraph.truncate(200))
        end
      end
    end
    alias_method :locations, :load_locations!

    def load_listings!
      @listings ||= do_task "Loading listings" do
        locations.map do |location|
          listing_types.sample(rand(1..3)).map do |listing_type|
            name = listing_type.name # TODO
            FactoryGirl.create(:listing, :listing_type => listing_type, :name => name, :location => location,
                               :description => Faker::Lorem.paragraph.truncate(200), :photos_count => 0)
          end
        end.flatten
      end
    end
    alias_method :listings, :load_listings!

    def load_reservations_for_dnm!
      do_task "Loading reservations for DNM" do
        company = companies.first
        period = 1.week.ago.to_date..1.week.from_now.to_date

        ## info@desksnear.me as a host
        listing = company.listings.first
        period.each do |date|
          create_reservation(listing, date, {:user => users.sample, :quantity => 1})
        end

        # info@desksnear.me as a guest
        creator = company.creator
        period.each do |date|
          create_reservation(listings.sample, date, {:user => creator, :quantity => 1})
        end

      end
    end

    def create_reservation(listing, date, attribs = {})
      begin
        reservation = listing.reservations.build(attribs)
        reservation.add_period(date)
        reservation.save!

        if [true, false].sample
          reservation.confirm!
          reservation.update_attribute :payment_status, Reservation::PAYMENT_STATUSES[:paid]
          reservation.update_attribute :payment_method, "credit_card"
          charge = Charge.new(
            :amount => reservation.total_amount_cents,
            :currency => reservation.currency,
            :reference => reservation,
            :success => true
          )
          charge.user = reservation.owner
          charge.save!
        end
        reservation
      rescue
      end
    end

    def clean_up!
      #Charge.update_all(:success => true)
    end


  end
end
