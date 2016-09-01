module CustomAttributes
  class CustomValidator

    include ::CustomAttributes::Concerns::Models::Castable

    def initialize(store_accessor_name)
      @store_accessor_name = store_accessor_name
    end

    def validate(record)
      return true if record.skip_custom_attribute_validation
      record.custom_attributes.each do |array|
        name = array[CustomAttribute::NAME]
        type = array[CustomAttribute::ATTRIBUTE_TYPE]
        validation_rules = array[CustomAttribute::VALIDATION_RULES]
        valid_values = array[CustomAttribute::VALID_VALUES]
        validation_only_on_update = array[CustomAttribute::VALIDATION_ONLY_ON_UPDATE]

        if validation_rules.present? && !validation_rules.empty? && !(validation_only_on_update && record.new_record?)
          validation_rules.each do |validation_rule_type, validation_rule_options|
            validation_rule_options ||= {}
            options = ({ attributes:  name }.merge(validation_rule_options)).symbolize_keys

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
            klass.new(options).validate(record.send(:"#{@store_accessor_name}"))
          end
        end
        value = record.send(:"#{@store_accessor_name}").send(name)
        if valid_values.present? && type.to_sym != :array && value.present?
          unless cast_valid_values(valid_values, type).include?(type == 'string' ? value.try(:downcase) : value)
            record.send(:"#{@store_accessor_name}").errors.add(name, :inclusion, value: value)
          end
        end
      end
    end

    def cast_valid_values(values, type)
      vals = values.map { |value| custom_property_type_cast(value, type.to_sym) }
      type == 'string' ? vals.map(&:downcase) : vals
    end

  end

end
