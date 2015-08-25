class TransformSpacerAvailabilityRulesToBe247 < ActiveRecord::Migration
  def up
    instance = Instance.find_by(name: 'Spacer')
    if instance.present?
      instance.try(:set_context!)
      instance.service_types.each do |tt|
        at = tt.availability_templates.first || tt.availability_templates.build
        at.name = "24/7"
        at.description = "Opened round the clock"
        at.availability_rules.destroy_all
        at.save!
        (0..6).each do |day|
          at.availability_rules.create!(day: day, open_hour: 0, open_minute: 0, close_hour: 23, close_minute: 59)
        end

        raise unless PlatformContext.current.present?
        Location.find_each do |location|
          location.availability_rules.destroy_all
          (0..6).each do |day|
            location.availability_rules.create!(day: day, open_hour: 0, open_minute: 0, close_hour: 23, close_minute: 59)
          end
        end

      end
    end
  end

  def down
  end
end

