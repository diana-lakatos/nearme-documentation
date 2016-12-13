# frozen_string_literal: true
module MarketplaceBuilder
  module CustomValidatorsBuilder
    def update_custom_validators_for_object(object, validators)
      validators ||= {}

      object.custom_validators.destroy_all

      validators.each do |validator|
        validator = validator.symbolize_keys
        field_name = validator.delete(:field_name)
        create_custom_validator(object, field_name, default_validator_properties.merge(validator))
        logger.debug "Creating custom validator for #{field_name}"
      end
    end

    def create_custom_validator(object, field_name, hash)
      hash = hash.with_indifferent_access
      custom_validator = object.custom_validators.where(field_name: field_name).first_or_initialize
      custom_validator.assign_attributes(hash)
      custom_validator.save!
    end

    def default_validator_properties
      {}
    end
  end
end
