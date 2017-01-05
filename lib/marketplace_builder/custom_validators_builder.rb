# frozen_string_literal: true
module MarketplaceBuilder
  module CustomValidatorsBuilder
    def update_custom_validators_for_object(object, validators)

      return cleanup_validators_for_object(object) if validators.empty?

      validators.each do |validator|
        validator = validator.symbolize_keys
        field_name = validator.delete(:field_name)
        create_custom_validator(object, field_name, validator)
      end
    end

    def create_custom_validator(object, field_name, hash)
      return cleanup_validators_for_object(object) if hash.empty?

      hash = default_validator_properties.merge(hash).with_indifferent_access
      custom_validator = object.custom_validators.where(field_name: field_name).first_or_initialize

      regex = hash.delete(:regex)
      if regex
        hash[:regex_validation] = true
        hash[:regex_expression] = regex
      end

      custom_validator.assign_attributes(hash)
      custom_validator.save!
      logger.debug "Creating custom validator for: #{field_name}"
      custom_validator
    end

    def cleanup_validators_for_object(object)
      object.custom_validators.destroy_all
    end

    def default_validator_properties
      {}
    end

    def whitelisted_properties
      %w(required regex valid_values max_length min_length validation_only_on_update)
    end
  end
end
