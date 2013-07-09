class FakeDataSeeder
  class WrongEnvironment < StandardError; end
  class NotEmptyDatabase < StandardError; end

  def go!
    validate!

    do_task "Loading data" do
      User.transaction do

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

        locations = do_task "Loading locations" do
          [
            :location_in_auckland, :location_in_adelaide, :location_in_cleveland, :location_in_san_francisco, :location_in_wellington,
            :location_ursynowska_address_components, :location_warsaw_address_components, :location_san_francisco_address_components,
            :location_vaughan_address_components
          ].map do |factory|
            FactoryGirl.build(factory, :amenities => amenities.sample(2), :location_type => location_types.sample).tap do |resource|
              resource.save!
            end
          end
        end

        listings = do_task "Loading listings" do
          locations.map do |location|
            FactoryGirl.build(:listing, :location => location).tap do |resource|
              resource.save!
            end
          end
        end

      end
    end

  end

  private

    def do_task(task_name = "")
      ActiveRecord::Migration.say_with_time(task_name) do
        yield
      end
    end

    def not_empty_database?
      do_task "Checking database" do
        # too bad we can't use this (due to records that are ):
        # Rails.application.eager_load!
        # ActiveRecord::Base.descendants.any? &:any?
        [Location, User, Company].any? &:any?
      end
    end

    def validate!
      do_task "Validating" do
        raise WrongEnvironment if wrong_env?
        raise NotEmptyDatabase if not_empty_database?
      end
    end

    def wrong_env?
      do_task "Checking environment" do
        Rails.env.production?
      end
    end

end

FakeDataSeeder.new.go!



