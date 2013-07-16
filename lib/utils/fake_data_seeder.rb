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

      def self.partners
        @partners ||= load_yaml("partners.yml")
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

          # === INSTANCES / PARTNERS =============================

          load_partners!
          load_instances!

          # === COMPANIES / LOCATIONS / LISTINGS =================

          load_users_and_companies!
          load_locations!
          load_listings!

          # === RESERVERATIONS ===================================

          load_reservations!

          clean_up!
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

    def load_amenities!
      @amenities ||= do_task "Loading amenities" do
        Data.amenities.each_with_index.map do |(amenity_type_name, amenity_names), index|
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
    end
    alias_method :amenities, :load_amenities!

    def load_industries!
      @industries ||= do_task "Loading industries" do
        Data.industries.map do |name|
          FactoryGirl.build(:industry, :name => name).tap do |resource|
            resource.save!
          end
        end
      end
    end
    alias_method :industries, :load_industries!

    def load_location_types!
      @location_types ||= do_task "Loading location types" do
        Data.location_types.map do |name|
          FactoryGirl.build(:location_type, :name => name).tap do |resource|
            resource.save!
          end
        end
      end
    end
    alias_method :location_types, :load_location_types!

    def load_listing_types!
      @listing_types ||= do_task "Loading listing types" do
        Data.listing_types.map do |name|
          FactoryGirl.build(:listing_type, :name => name).tap do |resource|
            resource.save!
          end
        end
      end
    end
    alias_method :listing_types, :load_listing_types!

    def load_partners!
      @partners ||= do_task "Loading partners" do
        Data.partners.map do |name|
          FactoryGirl.build(:partner, :name => name).tap do |resource|
            resource.save!
          end
        end
      end
    end
    alias_method :partners, :load_partners!

    def load_instances!
      @instances ||= do_task "Loading instances" do
        Data.instances.map do |name|
          FactoryGirl.build(:instance, :name => name).tap do |resource|
            resource.save!
          end
        end
      end
    end
    alias_method :instances, :load_instances!

    def load_users_and_companies!
      @users_and_companies ||= do_task "Loading users and companies" do
        users, companies = [], []
        Data.domains.map do |url|
          instance = instances.sample # TODO temp
          company_email = "#info@#{url}"
          user = FactoryGirl.build(:user, :name => Faker::Name.name, :email => company_email,
                                      :instance => instance, :industries => industries.sample(2)).tap do |resource|
            resource.save!
          end
          users << user

          companies << FactoryGirl.build(:company, :name => url, :email => user.email, :url => url,
                                         :instance => instance, :creator => user, :industries => user.industries).tap do |resource|
            resource.save!
          end
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

          FactoryGirl.build(:location, :amenities => amenities.sample(2), :location_type => location_types.sample,
                                         :company => company, :email => company.email, :address => address,
                                         :latitude => lat, :longitude => lng).tap do |resource|
            resource.save!
          end
        end
      end
    end
    alias_method :locations, :load_locations!

    def load_listings!
      @listings ||= do_task "Loading listings" do
        locations.map do |location|
          listing_types.sample(2).each do |listing_type|
            name = listing_type.name # TODO
            FactoryGirl.build(:listing, :listing_type => listing_type, :name => name, :location => location).tap do |resource|
              resource.save!
            end
          end
        end
      end
    end
    alias_method :listings, :load_listings!

    def load_reservations!
      @reservations ||= do_task "Loading reservations" do
        # we load reservations only for **first** company (desksnear.me)
        companies.first.listings.map do |listing|
          (1.week.ago.to_date..1.week.from_now.to_date).each do |date|
            begin
              reservation = listing.reservations.build(
                  :user => users.sample, # TODO
                  :quantity => 1
              )
              #reservation.payment_method = "credit_card"
              reservation.add_period(date)
              reservation.save!
              reservation.confirm!
            rescue
              # omnomnom
            end
          end
        end
      end
    end

    def clean_up!
      Charge.update_all(:success => true)
    end


  end
end
