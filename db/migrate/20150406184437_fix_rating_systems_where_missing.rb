class FixRatingSystemsWhereMissing < ActiveRecord::Migration
  def self.up
    Instance.find_each do |instance|
      PlatformContext.current = PlatformContext.new(instance)
      instance.transactable_types.each do |transactable_type|
        next if transactable_type.rating_systems.length > 0

        rating_systems_initializer_service = RatingSystemsInitializerService.new(transactable_type)
        rating_systems_initializer_service.create_rating_systems!
      end
    end
  end

  def self.down
  end
end
