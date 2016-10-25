class PopulateValidValuesCustomValidatorForCustomAttributes < ActiveRecord::Migration
  def up
    Instance.find_each do |instance|
      puts "Processing #{instance.name}"
      instance.set_context!
      CustomAttributes::CustomAttribute.where(validation_rules: ['null', '{}', '--- {}\n', '""']).update_all(validation_rules: nil)
      CustomAttributes::CustomAttribute.find_each do |ca|
        puts "\t#{ca.name}"
        ca.send(:ensure_custom_validators_are_properly_setup!)
        unless ca.validation_rules.blank?
          puts "\t\tPopulating custom validator for #{ca.validation_rules.inspect}"
          validator = ca.custom_validators.build(validation_rules: JSON.parse(ca.validation_rules), field_name: ca.name)
          validator.set_accessors
          validator.required = validator.required ? '1' : '0'
          validator.save!
        end
      end
    end
  end

  def down
  end
end
