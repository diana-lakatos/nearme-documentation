class FakeDataSeeder
  class WrongEnvironment < StandardError; end
  class NotEmptyDatabase < StandardError; end

  def go!
    validate

    do_task "Loading data" do
      User.transaction do

        coffee = FactoryGirl.build(:amenity, :name => "Coffee")
        coffee.save!

        wifi = FactoryGirl.build(:amenity, :name => "Wifi")
        wifi.save!
        kitchen = FactoryGirl.build(:amenity, :name => "Kitchen")
        kitchen.save!

        amenities = [
            [coffee],
            [coffee, wifi],
            [coffee, wifi, kitchen]
        ]

        locations = [
            FactoryGirl.build(:location_in_auckland, :amenities => amenities.sample),
            FactoryGirl.build(:location_in_cleveland, :amenities => amenities.sample),
            FactoryGirl.build(:location_in_san_francisco, :amenities => amenities.sample)
        ]

        locations.each do |location|
          location.save!
          FactoryGirl.build(:listing, :location => location).save!
        end

        ["Business", "Co-working", "Public"].each do |name|
          LocationType.new(:name => name).save!
        end

        business_location = LocationType.where(:name => "Business").first
        Location.update_all(:location_type_id => business_location)

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

    def validate
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



