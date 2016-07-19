class RequiredFieldChecker

  def initialize(object, attribute)
    @object = object
    @attribute = attribute.to_s
  end

  def required?
    is_required = @object.class.validators_on(@attribute).map(&:class).include?(ActiveRecord::Validations::PresenceValidator)
    if !is_required && (@object.try(:transactable_type).present? || @object.is_a?(User))
      is_required = @object.custom_validators.detect do |validator|
        validator.field_name == @attribute && !validator.validation_rules.try(:[], 'presence').nil?
      end.present?
    end

    is_required
  end

end

