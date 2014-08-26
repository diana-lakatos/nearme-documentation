class TransactableTypeAttributeValidator < ActiveModel::Validator
  def validate(record)
    transactable_type_attributes(record).each do |array|
      name = array[0]
      type = array[1]
      validation_rules = array[2]
      valid_values = array[3]
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

  def transactable_type_attributes(record)
    TransactableTypeAttribute.where(transactable_type_id: record.transactable_type_id).pluck([:name, :attribute_type, :validation_rules, :valid_values])
  end
end

