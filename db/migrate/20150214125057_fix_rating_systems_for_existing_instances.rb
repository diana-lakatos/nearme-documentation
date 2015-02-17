class FixRatingSystemsForExistingInstances < ActiveRecord::Migration
  def up
    Instance.find_each do |instance|
      PlatformContext.current = PlatformContext.new(instance)
      instance.transactable_types.each do |transactable_type|
        [instance.lessor, instance.lessee, instance.bookable_noun].each do |subject|
          rating_system = instance.rating_systems.where(subject: subject, transactable_type_id: transactable_type.id).first_or_create
          RatingConstants::VALID_VALUES.each { |value| rating_system.rating_hints.where(value: "#{value}", instance: instance).first_or_create }
        end
      end
    end
  end

  def down
  end
end
