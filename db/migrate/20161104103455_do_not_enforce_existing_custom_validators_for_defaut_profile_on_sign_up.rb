# frozen_string_literal: true
class DoNotEnforceExistingCustomValidatorsForDefautProfileOnSignUp < ActiveRecord::Migration
  def change
    Instance.find_each do |i|
      i.set_context!
      InstanceProfileType.where(profile_type: 'default').all.select { |ipt| ipt.custom_validators.count > 0 }.each do |ipt|
        puts "Updating #{i.name}:"
        puts "\t#{ipt.custom_validators.pluck(:field_name).join(', ')}"
        ipt.custom_validators.update_all(validation_only_on_update: true)
      end
    end
  end
end
