module CustomAttributes
  class Validator < ActiveModel::Validator
    def validate(record)
      return true if record.skip_custom_attribute_validation
      return true if !record.respond_to?(:properties) || !record.properties.kind_of?(CustomAttributes::CollectionProxy)
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
        if valid_values.present? && type.to_sym != :array && record.properties[name].present?
          unless valid_values.map { |s| s.mb_chars.downcase }.include?(record.properties[name].try(:mb_chars).try(:downcase))
            record.errors.add(name, :inclusion, value: record.properties[name])
          end
        end
      end
    end

  end

end
