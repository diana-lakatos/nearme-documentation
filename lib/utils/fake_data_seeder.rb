module Utils
  class FakeDataSeeder

    class WrongEnvironmentError < StandardError; end
    class NotEmptyDatabaseError < StandardError; end

    module Data

      def self.instance_admin_roles
        @instance_admin_roles ||= load_yaml("instance_admin_roles.yml")
      end

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

      def self.domains
        @domains ||= load_yaml("domains.yml")
      end

      def self.instances
        @instances ||= load_yaml("instances.yml")
      end

      def self.top_cities
        @top_cities ||= load_yaml("top_cities.yml")
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
      if Rails.env.test?
        ActiveRecord::Migration.suppress_messages { yield }
      else
        ActiveRecord::Migration.say_with_time(task_name) { yield }
      end
    end

    def load_data!
      do_task "Loading data" do
        User.transaction do

          # === INSTANCES ========================================

          load_instances!
          PlatformContext.current = PlatformContext.new(Instance.first)
          # === BASIC STUFF ======================================

          load_instance_admin_roles!
          load_amenities!
          load_industries!
          load_location_types!
          load_transactable_types!

          # === COMPANIES / LOCATIONS / LISTINGS =================

          load_users_and_companies!
          load_instance_admins!
          load_locations!
          load_listings!

          # === RESERVERATIONS ===================================

          load_reservations_for_dnm!

          # === BILLING GATEWAYS CREDENTIALS =====================

          load_integration_keys!

          # === BLOG ========================================

          load_blog_posts!

          # === USER BLOG ========================================

          load_user_blog_posts!

          clean_up!
        end
      end

    end

    def not_empty_database?
      do_task "Checking database" do
        # too bad we can't use this (due to records that are ):
        # Rails.application.eager_load!
        # ActiveRecord::Base.descendants.any? &:any?
        [Location, User, Company, Instance].any?(&:any?)
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

    def load_instance_admin_roles!
      @instance_admin_roles ||= do_task "Loading roles" do
        Data.instance_admin_roles.each_with_index.map do |(name), index|
        FactoryGirl.create("instance_admin_role_#{name.downcase}")
        end
      end
    end
    alias_method :instance_admin_roles, :load_instance_admin_roles!

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

    def load_instance_admins!
      do_task "Loading instance admins" do
        InstanceAdmin.create(:user_id => users.first.id, :instance_id => Instance.first.id)
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

    def load_transactable_types!
      tp = TransactableType.where(name: 'Listing').first_or_initialize
      tp.attributes = FactoryGirl.attributes_for(:transactable_type_listing)
      tp.save!
    end

    def load_listings!
      @listings ||= do_task "Loading listings" do
        locations.map do |location|

          ListingType.all.sample(rand(1..4)).map do |lt|
            transactable = FactoryGirl.build(:transactable, :listing_type_id => lt.id, :name => "#{lt.name} #{Faker::Company.name}".truncate(50, :separator => ''), :location => location,
                               :description => Faker::Lorem.paragraph.truncate(200), :photos_count => 0)
            transactable.save(:validate => false)
            transactable
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

    def load_integration_keys!
      dnm_instance = Instance.first

      [
        {
          type: "PaymentGateway::StripePaymentGateway", 
          test_settings: { login: "sk_test_sPLnOkI5mvXCoUuaqi5j6djR" },
          live_settings: { login: "sk_live_qfvqBDKaG1guI1wuorkgLI7Y" }
        },
        {
          type: "PaymentGateway::PaypalPaymentGateway", 
          test_settings: { 
            email: "lemkowski-facilitator@gmail.com", 
            login: "lemkowski-facilitator_api1.gmail.com", 
            password: "Y6C36E7MFJXDPR2R", 
            signature: "ArlmEAw8pfNvMKXKC-AaWEzRgFraAzAbIZ3ybNtEPynnqHCO.XUNcqR4" 
          },
          live_settings: { 
            email: "lemkowski-facilitator@gmail.com", 
            login: "lemkowski-facilitator_api1.gmail.com", 
            password: "Y6C36E7MFJXDPR2R", 
            signature: "ArlmEAw8pfNvMKXKC-AaWEzRgFraAzAbIZ3ybNtEPynnqHCO.XUNcqR4" 
          }
        },

        {
          type: "PaymentGateway::BraintreeMarketplacePaymentGateway", 
          test_settings: { 
            merchant_id: "jry7nqs72wcsqxtr",
            public_key: "7g9bjxznhnc2x244",
            private_key: "cd6dc220d0585d332709d13497c8873b",
            supported_currency: "USD"
          },
          live_settings: { 
            merchant_id: "jry7nqs72wcsqxtr",
            public_key: "7g9bjxznhnc2x244",
            private_key: "cd6dc220d0585d332709d13497c8873b",
            supported_currency: "USD"
          }
        }
      ].each do | payment_gateway |
        PaymentGateway.create(payment_gateway.merge(instance_id: dnm_instance.id))
      end


      dnm_instance.facebook_consumer_key = '432038396866156'
      dnm_instance.facebook_consumer_secret = '71af86082de1c38a3523a4c8f44aca2d'

      dnm_instance.twitter_consumer_key = 'IZeQXx4YyCdTQ9St3tmyw'
      dnm_instance.twitter_consumer_secret = 'ZlxMPIhNPBn4QbOSHqkN1p7hKghGZTOtR1fDsPSX8'

      dnm_instance.linkedin_consumer_key = '4q9xfgn60bik'
      dnm_instance.linkedin_consumer_secret = 'lRmKVrc0RPpfKDCV'

      dnm_instance.instagram_consumer_key = '566499e0d6e647518d8f4cec0a42f3d6'
      dnm_instance.instagram_consumer_secret = '5c0652ad06984bf09e4987c8fc5ea8f1'

      dnm_instance.save!
    end

    def create_reservation(listing, date, attribs = {})
      begin
        reservation = listing.reservations.build(attribs)
        reservation.add_period(date)
        reservation.save!

        if [true, false].sample
          reservation.confirm!
          reservation.mark_as_paid!
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

    def load_blog_posts!
      do_task "Loading blog posts" do

        # NearMe blog instance
        near_me_blog_instance = BlogInstance.new(name: 'NearMe Blog', enabled: true)
        near_me_blog_instance.owner_type = 'near-me'
        near_me_blog_instance.save!

        # Other blog instances
        Instance.all.each do |instance|
          blog_instance = BlogInstance.new(name: instance.name + ' Blog', enabled: true)
          blog_instance.owner = instance
          blog_instance.save!
        end

        # BlogPosts
        BlogInstance.all.each do |blog_instance|
          15.times do |i|
            blog_instance.blog_posts.create!(title: Faker::Lorem.words(rand(5) + 1).join(" ").titleize,
                                             content: Faker::Lorem.paragraph,
                                             author_name: Faker::Name.name,
                                             author_biography: Faker::Lorem.paragraph,
                                             published_at: i.weeks.ago,
                                             created_at: i.weeks.ago,
                                             user: User.last)
          end
        end
      end
    end

    def load_user_blog_posts!
      do_task 'Loading user blog posts' do

        User.all.each do |user|
          next unless user.blog

          user_blog = user.blog
          user_blog.enabled = true
          user_blog.name = "#{user.name}'s blog"
          user_blog.save!

          5.times do
            created_at = rand(10).weeks.ago
            blog_post = { title: Faker::Lorem.words(rand(5) + 1).join(' ').titleize,
                          content: Faker::Lorem.paragraphs(3).join('<br/><br/>').titleize,
                          excerpt: Faker::Lorem.paragraph(1) }

            user.blog_posts.create!(title: blog_post[:title], content: blog_post[:content],
                                    excerpt: blog_post[:excerpt], author_name: user.name,
                                    author_biography: Faker::Lorem.paragraph, created_at: created_at,
                                    published_at: created_at + rand(4).days)
          end
        end
      end
    end

  end
end
