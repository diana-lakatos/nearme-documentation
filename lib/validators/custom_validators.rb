class CustomValidators < ActiveModel::Validator
  def validate(record)
    @record = record
    return true if should_skip_validation?
    invoke_validators(@record, @record.custom_validators)
    return true if should_skip_custom_attributes_validation?
    @record.custom_attributes_custom_validators.each do |data_store_name, validators|
      invoke_validators(@record.send(data_store_name), validators)
      @record.send(:"#{data_store_name}")
             .errors
             .full_messages.each { |message| @record.errors.add(:"#{data_store_name}", message) }
    end
  end

  protected

  def invoke_validators(data_source, validators)
    validators.each do |validator|
      next if should_skip_validator?(validator)
      invoke_validation(data_source, validator)
    end
  end

  def invoke_validation(data_source, validator)
    hash = { record: data_source, field_name: validator.field_name }
    StandardValidator.new(hash.merge(validation_rules: validator.validation_rules))
                     .validate
    ValidValuesValidator.new(hash.merge(valid_values: validator.valid_values))
                        .validate
    RegexpValidator.new(hash.merge(regexp: validator.regex_expression))
                   .validate
  end

  def should_skip_validation?
    @record.try(:draft?)
  end

  def should_skip_custom_attributes_validation?
    !@record.respond_to?(:custom_attributes_custom_validators) || @record.skip_custom_attribute_validation
  end

  def should_skip_validator?(validator)
    validator.validation_only_on_update? && @record.new_record?
  end

  def custom_attributes_custom_validators
    @record.try(:custom_attributes_custom_validators) || []
  end
end
