class TransactableTypeAttributeValidator < ActiveModel::Validator
  def validate(record)
    record.transactable_type_attributes.each do |tta|
      if tta.validation_rules.present? && !tta.validation_rules.empty?
        tta.validation_rules.each do |validation_rule_type, validation_rule_options|
          validation_rule_options ||= {}
          name = validation_rule_options.fetch("redirect", tta.name)
          options = ({ attributes: name }.merge(validation_rule_options)).symbolize_keys

          klass = case validation_rule_type.to_sym
                  when :presence
                    ActiveModel::Validations::PresenceValidator
                  when :inclusion
                    ActiveModel::Validations::InclusionValidator
                  when :numericality
                    ActiveModel::Validations::NumericalityValidator
                  when :length
                    ActiveModel::Validations::LengthValidator
                  else
                    raise "Unknown validation type: #{validation_rule_type}"
                  end
          klass.new(options).validate(record)
        end
      end
      if tta.valid_values.present?
        options = { attributes: tta.name, in: tta.valid_values  }
        ActiveModel::Validations::InclusionValidator.new(options).validate(record)
      end
    end
  end
end

