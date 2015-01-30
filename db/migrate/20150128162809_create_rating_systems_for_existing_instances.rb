class CreateRatingSystemsForExistingInstances < ActiveRecord::Migration
  def up
    Instance.all.each do |instance|
      instance.rating_systems.each do |rating_system|
        existing_values = rating_system.rating_hints.pluck(:value).map(&:to_i)
        (RatingConstants::VALID_VALUES.to_a - existing_values).each do |value|
          rating_system.rating_hints.create(value: value, instance_id: rating_system.instance_id)
        end
      end
    end

    rating_systems_instance_ids = RatingSystem.pluck(:instance_id).uniq.compact
    Instance.where.not(id: rating_systems_instance_ids).each do |instance|
      instance.transactable_types.each do |transactable_type|
        [instance.lessor, instance.lessee, instance.bookable_noun].each do |subject|
          rating_system = instance.rating_systems.create(subject: subject, transactable_type_id: transactable_type.id)
          RatingConstants::VALID_VALUES.each { |value| rating_system.rating_hints.create(value: value, instance: instance) }
        end
      end
    end
  end

  def down
  end
end
