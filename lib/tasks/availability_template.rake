namespace :at do
  task update_24h: :environment do
    tt = TransactableType.find(55) # change X
    tt.instance.set_context!
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

  desc 'Adds template 24/7 to all instances'
  task add_24h_to_instances: :environment do
    Instance.find_each do |i|
      i.set_context!
      AvailabilityTemplate.create!(
        name: "24/7",
        parent: i,
        description: "Sunday - Saturday, 12am-11:59pm",
        availability_rules_attributes: [{ open_hour: 0, open_minute: 0, close_hour: 23, close_minute: 59, days: (0..6).to_a }]
      )
    end
  end

  desc 'Fix parents for AvailabilityTemplates'
  task fix_parents: :environment do
    Instance.find_each do |i|
      i.set_context!
      AvailabilityTemplate.where(parent_type: nil).find_each do |at|
        if AvailabilityTemplate.where(parent: i, name: at.name, description: at.description).exists?
          at.destroy
        else
          at.parent = i
          at.save!
          p "Updated AvailabilityTemplate #{at.id}"
        end
      end
    end
  end

  desc 'Create AvailabilityTemplates for Locations'
  task create_templates_for_locations: :environment do
    class Location < ActiveRecord::Base
      has_paper_trail
      scoped_to_platform_context
      has_many :availability_rules, -> { order('day ASC') }, :as => :target
      belongs_to :availability_template
      has_many :availability_templates, as: :parent
      belongs_to :instance

      def includes_rule?(availability_rules, rule)
        availability_rules.find do |existing_rule|
          (rule.days & existing_rule.days == rule.days) && existing_rule.open_hour == rule.open_hour && existing_rule.close_hour == rule.close_hour &&
            existing_rule.open_minute == rule.open_minute && existing_rule.close_minute == rule.close_minute
        end
      end

      def matches_template?(summary, template)
        summary.each_day do |day, rule|
          next if !rule && !template.availability_rules.pluck(:days).flatten.include?(day)
          return false unless rule && includes_rule?(template.availability_rules, rule)
        end
        true
      end

      def find_availability_template_id
        availability = AvailabilityRule::Summary.new(availability_rules)
        template = AvailabilityTemplate.where(parent: instance).try(:detect) { |template| matches_template?(availability, template) }
        template.try(:id)
      end
    end

    Instance.find_each do |i|
      i.set_context!
      Location.all.find_each.with_index do |location, i|
        next unless location.availability_template.nil?
        if location.availability_rules.any?
          at_id = location.find_availability_template_id
          if at_id.nil?
            at = location.availability_templates.new(name: 'Custom location availability', availability_rules: location.availability_rules)
            if at.save
              at_id = at.id
            else
              at_id = AvailabilityTemplate.first.try(:id)
            end
          else
            location.availability_rules.destroy_all
          end
        elsif
          at_id = AvailabilityTemplate.first.try(:id)
        end
        location.update_column :availability_template_id, at_id
        p "Updated Location #{location.id} with AvailabilityTemplate #{at_id}"
      end
    end
  end

  desc 'Create AvailabilityTemplates for Transactable'
  task create_templates_for_transactables: :environment do
    class Transactable < ActiveRecord::Base
      has_paper_trail
      scoped_to_platform_context
      has_many :availability_rules, -> { order('day ASC') }, :as => :target
      belongs_to :availability_template
      has_many :availability_templates, as: :parent
      belongs_to :instance
      belongs_to :location

      def includes_rule?(availability_rules, rule)
        availability_rules.find do |existing_rule|
          (rule.days & existing_rule.days == rule.days) && existing_rule.open_hour == rule.open_hour && existing_rule.close_hour == rule.close_hour &&
            existing_rule.open_minute == rule.open_minute && existing_rule.close_minute == rule.close_minute
        end
      end

      def matches_template?(summary, template)
        summary.each_day do |day, rule|
          next if !rule && !template.availability_rules.pluck(:days).flatten.include?(day)
          return false unless rule && includes_rule?(template.availability_rules, rule)
        end
        true
      end

      def find_availability_template_id
        availability = AvailabilityRule::Summary.new(availability_rules)
        template = AvailabilityTemplate.for_parents([instance, location]).try(:detect) { |template| matches_template?(availability, template) }
        template.try(:id)
      end
    end

    Instance.find_each do |i|
      i.set_context!
      Transactable.all.find_each do |transactable|
        next unless transactable.availability_template_id.nil?
        if transactable.availability_rules.any?
          at_id = transactable.find_availability_template_id
          if at_id.nil?
            at = transactable.availability_templates.new(name: 'Custom transactable availability', availability_rules: transactable.availability_rules)
            if at.save
              at_id = at.id
            else
              at_id = AvailabilityTemplate.first.try(:id)
            end
          else
            transactable.availability_rules.destroy_all
          end
        elsif
          at_id = AvailabilityTemplate.first.try(:id)
        end
        transactable.update_column :availability_template_id, at_id
        p "Updated Transactable #{transactable.id} with AvailabilityTemplate #{at_id}"
      end
    end

  end

  desc 'Migrates AvailabilityTemplates & AvailabilityRules to new UI'
  task :migrate_to_new_ui => [:environment] do
    tasks = ['availability_rules:convert', 'availability_rules:delete_old', 'at:add_24h_to_instances',
      'at:fix_parents', 'at:create_templates_for_locations', 'at:create_templates_for_transactables' ]
    tasks.each do |task_name|
      p "[#{Time.now}]Invoking: #{task_name}"
      Rake::Task[task_name].invoke
    end
  end

end

