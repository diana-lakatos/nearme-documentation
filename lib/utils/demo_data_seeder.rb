require 'timecop'

module Utils
  class DemoDataSeeder

    module Data
      def self.amenities
        @amenities ||= load_yaml("amenities.yml")
      end

      def self.addresses
        @addresses ||= load_demo_yaml("addresses.yml")
      end

      def self.industries
        @industries ||= load_yaml("industries.yml")
      end

      def self.location_types
        @location_types ||= load_yaml("location_types.yml")
      end

      def self.listing_types
        @listing_types ||= load_demo_yaml("listing_types.yml")
      end

      def self.domains
        @domains ||= load_demo_yaml("domains.yml")
      end

      def self.instances
        @instances ||= load_yaml("instances.yml")
      end

      private

        def self.load_demo_yaml(collection)
          YAML.load_file(Rails.root.join('db', 'seeds', 'demo', collection))
        end

        def self.load_yaml(collection)
          YAML.load_file(Rails.root.join('db', 'seeds', collection))
        end

    end

    def go!
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
          generate_impressions!

          # === RESERVERATIONS ===================================

          load_reservations_for_dnm!

          puts "\e[32mUser created with email: #{@user.email} and password: #{@user.password}\e[0m"
        end
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
        Data.domains.each_with_index.map do |url, index|
          company_email = "info@#{url}"
          user = FactoryGirl.create(:demo_user, :name => Faker::Name.name, :email => company_email,
                                    :biography => Faker::Lorem.paragraph.truncate(200),
                                    :industries => industries.sample(2))
          users << user

          @user ||= user

          if index <= 3
            company = FactoryGirl.create(:company_with_paypal_email, :name => url, :email => user.email, :url => url,
                                            :description => Faker::Lorem.paragraph.truncate(200),
                                            :creator => user, :industries => user.industries)
            company.users << user unless company.users.include?(user)
            companies << company
          elsif index <= 5
            companies.first.users << user
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
          company = address.include?('Los Angeles') ? companies.first : (companies - [companies.first]).sample

          FactoryGirl.create(:location, :amenities => amenities.sample(2), :location_type => location_types.sample,
                             :company => company, :email => company.email, :address => address,
                             :latitude => lat, :longitude => lng, :description => Faker::Lorem.paragraph.truncate(200))
        end
      end
    end
    alias_method :locations, :load_locations!

    def load_listings!
      @listings ||= do_task "Loading listings" do
        @locations.map do |location|
          listing_types.sample(rand(1..3)).map do |listing_type|
            name = "#{listing_type.name} #{Faker::Company.name}"
            FactoryGirl.create(:demo_listing, :listing_type => listing_type, :name => name, :location => location,
                               :description => Faker::Lorem.paragraph.truncate(200), :photos_count => 0)
          end
        end.flatten
      end
    end
    alias_method :listings, :load_listings!

    def generate_impressions!
      do_task "Generating impressions" do
        period = 1.month.ago.to_date..Date.current

        companies.each do |company|
          company.locations.each do |location|
            period.each do |date|
              Timecop.freeze(date) do
                1.upto(rand(3).to_i) do
                  impression = location.track_impression
                  impression.save!
                end
              end
            end
          end
        end
      end
    end

    def load_reservations_for_dnm!
      do_task "Loading reservations for DNM" do
        company = companies.first
        period = 1.week.ago.to_date..1.week.from_now.to_date

        ## info@desksnear.me as a host
        [[2.days.from_now.to_date, 2], [1.week.from_now.to_date, 4], [8.days.ago.to_date, 6]].each_with_index do |initial_date, date_index|
          date = initial_date.first
          initial_date.second.times do |index|
            listing = company.listings.sample
            Timecop.freeze(date + 1.day) do
              date = listing.first_available_date
            end
            Timecop.freeze(date) do
              (date_index == 1 ? 2 : 1).times do
                create_reservation(listing, date, date_index > 0, {:user => (users - [@user]).sample, :quantity => 1, :currency => 'USD'})
                listing = company.listings.sample
              end
            end
          end
        end

        # info@desksnear.me as a guest
        creator = company.creator 
        [1.week.ago.to_date, 1.day.from_now.to_date].each do |initial_date|
          date = initial_date
          2.times do |index|
            begin
              other_company = (companies - [company]).sample
            end while other_company.locations.empty?
            listing = other_company.listings.sample
            Timecop.freeze(date + 1.day) do
              date = listing.first_available_date
            end
            Timecop.freeze(date) do
              reservation_date = listing.first_available_date
              create_reservation(listing, reservation_date, index.zero?, {:user => creator, :quantity => 1, :currency => 'USD'})
            end
          end
        end
      end
    end

    def create_reservation(listing, date, confirmed, attribs = {})
      begin
        reservation = listing.reservations.build(attribs)
        reservation.add_period(date)
        reservation.save!

        if confirmed
          reservation.confirm!
          reservation.update_attribute :payment_status, Reservation::PAYMENT_STATUSES[:paid]
          reservation.update_attribute :payment_method, "credit_card"

          reservation_charge = reservation.reservation_charges.create!(
            subtotal_amount: reservation.subtotal_amount,
            service_fee_amount: reservation.service_fee_amount,
            paid_at: Time.zone.now
          )

          charge = Charge.new(
            :amount => reservation.total_amount_cents,
            :currency => reservation.currency,
            :reference => reservation_charge,
            :success => true
          )
          charge.user = reservation.owner
          charge.save!

          payment_transfer = listing.company.payment_transfers.create!(
            reservation_charges: [reservation_charge]
          )

          payment_transfer.mark_transferred
        end
        reservation
      rescue
      end
    end

  end
end

