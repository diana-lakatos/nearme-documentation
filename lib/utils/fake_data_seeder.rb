module Utils
  class FakeDataSeeder
    class WrongEnvironmentError < StandardError; end
    class NotEmptyDatabaseError < StandardError; end

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

          industries = do_task "Loading industries" do
            ["Automotive", "Design", "Entertainment", "Fine Art", "Music"].map do |name|
              FactoryGirl.build(:industry, :name => name).tap do |resource|
                resource.save!
              end
            end
          end

          partners = do_task "Loading partners" do
            ["Mega desks", "Super desks", "Cool desksu"].map do |name|
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

          users = do_task "Loading users" do
            ["michelle", "sai"].map do |name|
              instance = instances.sample # TODO temp
              FactoryGirl.build(:user, :name => name.capitalize, :email => "#{name}@desksnear.me",
                                :instance => instance, :industries => industries.sample(2)).tap do |resource|
                resource.save!
              end
            end
          end

          companies = do_task "Loading companies" do
            ["megadesks.net", "superdesks.net", "cooldesks.net"].map do |url|
              creator = users.sample
              instance = instances.sample # TODO temp
              FactoryGirl.build(:company, :name => url, :email => "info@#{url}", :url => url,
                                :instance => instance, :creator => creator, :industries => creator.industries).tap do |resource|
                resource.save!
              end
            end
          end

          amenities = do_task "Loading amenities" do
            ["Coffee", "Wifi", "Kitchen"].map do |a|
              FactoryGirl.build(:amenity, :name => a).tap do |resource|
                resource.save!
              end
            end
          end

          location_types = do_task "Loading location types" do
            ["Business", "Co-working", "Public"].map do |name|
              FactoryGirl.build(:location_type, :name => name).tap do |resource|
                resource.save!
              end
            end
          end

          listing_types = do_task "Loading listing types" do
            ["Private office", "Meeting room", "Shared desks"].map do |name|
              FactoryGirl.build(:listing_type, :name => name).tap do |resource|
                resource.save!
              end
            end
          end

          locations = do_task "Loading locations" do
            [
                :location_in_auckland, :location_in_adelaide, :location_in_cleveland, :location_in_san_francisco, :location_in_wellington,
                :location_ursynowska_address_components, :location_warsaw_address_components, :location_san_francisco_address_components,
                :location_vaughan_address_components
            ].map do |factory|
              company = companies.sample
              FactoryGirl.build(factory, :amenities => amenities.sample(2), :location_type => location_types.sample,
                                :company => company, :email => company.email).tap do |resource|
                resource.save!
              end
            end
          end

          do_task "Loading listings" do
            locations.each do |location|
              listing_types.sample(2).each do |listing_type|
                FactoryGirl.build(:listing, :listing_type => listing_type, :name => listing_type.name, :location => location).tap do |resource|
                  resource.save!
                end
              end
            end
          end

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
