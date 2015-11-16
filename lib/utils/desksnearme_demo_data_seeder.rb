include ActiveSupport::Testing::TimeHelpers

module Utils
  class DesksnearmeDemoDataSeeder < Utils::DemoDataSeeder

    Data.class_eval do
      def self.load_demo_yaml(collection)
        YAML.load_file(Rails.root.join('db', 'seeds', 'demo', 'desksnearme', collection))
      end
    end

    protected

    def load_data!
      do_task "Loading data" do
        User.transaction do

          # === INSTANCES ========================================

          load_instances!
          PlatformContext.current = PlatformContext.new(Intance.first)

          # === BASIC STUFF ======================================

          load_amenities!
          load_industries!
          load_location_types!
          load_transactable_types!

          # === COMPANIES / LOCATIONS / LISTINGS =================

          load_users_and_companies!
          load_locations!
          load_listings!
          generate_impressions!

          # === MESSAGES =========================================

          generate_user_messages!

          # === RESERVATIONS ===================================

          load_reservations_for_dnm!

          # === BILLING GATEWAYS CREDENTIALS =====================

          load_stripe_api_keys_for_dnm!

          puts "\e[32mUser created with email: #{@user.email} and password: #{@user.password}\e[0m"
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
            travel_to(date + 1.day) do
              date = listing.first_available_date
            end
            travel_to(date) do
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
            travel_to(date + 1.day) do
              date = listing.first_available_date
            end
            travel_to(date) do
              reservation_date = listing.first_available_date
              create_reservation(listing, reservation_date, index.zero?, {:user => creator, :quantity => 1, :currency => 'USD'})
            end
          end
        end
      end
    end

  end
end
