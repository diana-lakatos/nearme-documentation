module CustomAttributes
  class Validator < ActiveModel::Validator
    def validate(record)
      record.custom_attributes.each do |array|
        name = array[CustomAttribute::NAME]
        type = array[CustomAttribute::ATTRIBUTE_TYPE]
        validation_rules = array[CustomAttribute::VALIDATION_RULES]
        valid_values = array[CustomAttribute::VALID_VALUES]

        if validation_rules.present? && !validation_rules.empty?
          validation_rules.each do |validation_rule_type, validation_rule_options|
            validation_rule_options ||= {}
            name = validation_rule_options.fetch("redirect", name)
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
        if valid_values.present? && type.to_sym != :array
          options = { attributes: name, in: valid_values  }
          ActiveModel::Validations::InclusionValidator.new(options).validate(record)
        end
      end
    end

  end

end
