include ActiveSupport::Testing::TimeHelpers

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

      def self.domains
        @domains ||= load_demo_yaml("domains.yml")
      end

      def self.instances
        @instances ||= load_yaml("instances.yml")
      end

      protected

      def self.load_demo_yaml(collection)
        raise NotImplementedError
      end

      def self.load_yaml(collection)
        YAML.load_file(Rails.root.join('db', 'seeds', collection))
      end
    end

    def go!
      load_data!
    end

    protected

    def do_task(task_name = "")
      ActiveRecord::Migration.say_with_time(task_name) do
        yield
      end
    end

    def load_data!
      raise NotImplementedError
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

    def load_transactable_types!
      tp = TransactableType.where(name: 'Listing').first_or_create!
      tp.attributes = FactoryGirl.attributes_for(:transactable_type_listing)
      tp.save!
    end

    def load_listings!
      @listings ||= do_task "Loading listings" do
        @locations.map do |location|
          ["Shared Desks", "Meeting Room", "Private Office"].sample(rand(1..3)).map do |listing_type_name|
            name = "#{listing_type_name} #{Faker::Company.name}"
            FactoryGirl.create(:demo_listing, :listing_type => listing_type_name, :name => name, :location => location,
                               :description => Faker::Lorem.paragraph.truncate(200), :photos_count_to_be_created => 0)
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
              travel_to(date) do
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

    def generate_user_messages!
      users.each do |user|
        recipient = users.sample

        user_message = user.authored_messages.new(body: "Hi #{recipient.name}!")
        user_message.set_message_context_from_request_params(user_id: recipient.id)
        user_message.save!
      end

      listings.sample(20).each do |listing|
        author = users.sample

        user_message = author.authored_messages.new(body: "Question about #{listing.name}.")
        user_message.set_message_context_from_request_params(listing_id: listing.id)
        user_message.save!
      end
    end

    def load_integration_keys!
      dnm_instance = Instance.first
      create_payment_gateways
      @stripe = PaymentGateway.where(name: "Stripe").first


      if dnm_instance
        settings = { login: 'sk_test_lpr4WQXQdncpXjjX6IJx01W7' }
        InstancePaymentGateway.create(instance_id: dnm_instance.id, payment_gateway_id: @stripe.id, live_settings: settings, test_settings: settings)

        dnm_instance.facebook_consumer_key = '491810927536381'
        dnm_instance.facebook_consumer_secret = 'cce1576ac9f3c4d6998f2c9345360afe'

        dnm_instance.twitter_consumer_key = '8M9qYWg2v2hjTotXg9cWw'
        dnm_instance.twitter_consumer_secret = 'qnP1hPJ1kb2AaN7XTTfN3K4VT3SRN48UWe3vMNtVfEg'

        dnm_instance.linkedin_consumer_key = '26pmsiwpsh8a'
        dnm_instance.linkedin_consumer_secret = 'M2TZrt7sF7QlIeUZ'

        dnm_instance.instagram_consumer_key = 'f9aee2b90cc5493bb60f777fee06af52'
        dnm_instance.instagram_consumer_secret = '8b20585b0edd47e7b5ed090616c24d0b'
        dnm_instance.save!
      end
    end

    def create_payment_gateways
      # create default payment_gateways
      stripe_settings = { login: "" }
      balanced_settings = { login: "" }
      paypal_settings = { email: "", login: "", password: "", signature: "", app_id: "" }
      swipe_settings = { login: "", api_key: "" }
      sagepay_settings = { login: "", password: "" }
      worldpay_settings = { login: "" }
      paystation_settings = { paystation_id: "", gateway_id: "" }
      authorize_net_settings = { login: "", password: "" }
      ogone_settings = { login: "", user: "", password: "" }
      spreedly_settings = { login: "", password: "", gateway_token: "" }

      payment_gateways = [
        {
          name: "Stripe",
          settings: stripe_settings,
          active_merchant_class: "ActiveMerchant::Billing::StripeGateway"
        },
        {
          name: "Balanced",
          settings: balanced_settings,
          active_merchant_class: "ActiveMerchant::Billing::BalancedGateway"
        },
        {
          name: "PayPal",
          settings: paypal_settings,
          active_merchant_class: "ActiveMerchant::Billing::PaypalGateway"
        },
        {
          name: "SagePay",
          settings: sagepay_settings,
          active_merchant_class: "ActiveMerchant::Billing::SagePayGateway"
        },
        {
          name: "Worldpay",
          settings: worldpay_settings,
          active_merchant_class: "ActiveMerchant::Billing::WorldpayGateway"
        },
        {
          name: "Paystation",
          settings: paystation_settings,
          active_merchant_class: "ActiveMerchant::Billing::PaystationGateway"
        },
        {
          name: "AuthorizeNet",
          settings: authorize_net_settings,
          active_merchant_class: "ActiveMerchant::Billing::AuthorizeNetGateway"
        },
        {
          name: "Ogone",
          settings: ogone_settings,
          active_merchant_class: "ActiveMerchant::Billing::OgoneGateway"
        },
        {
          name: "Spreedly",
          settings: spreedly_settings,
          active_merchant_class: "ActiveMerchant::Billing::SpreedlyCoreGateway"
        },
      ]

      PaymentGateway.create(payment_gateways)
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

          payment = reservation.payments.create!(
            subtotal_amount: reservation.subtotal_amount,
            service_fee_amount: reservation.service_fee_amount,
            paid_at: Time.zone.now
          )

          charge = Charge.new(
            :amount => reservation.total_amount_cents,
            :currency => reservation.currency,
            :reference => payment,
            :success => true
          )
          charge.user = reservation.owner
          charge.save!

          payment_transfer = listing.company.payment_transfers.create!(
            payments: [payment]
          )

          payment_transfer.mark_transferred
        end
        reservation
      rescue
      end
    end

  end
end
