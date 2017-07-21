# frozen_string_literal: true
class CustomizationsForm < BaseForm
  POPULATOR = lambda do |collection:, fragment:, index:, as:, **_args|
    name_to_custom_model_type_hash ||= {}
    custom_model_type = name_to_custom_model_type_hash[as] ||= CustomModelType.with_parameterized_name(as)
    raise ArgumentError, "Custom model #{as} does not exist. Did you mean one of: #{CustomModelType.pluck(:parameterized_name).join(',')} ?" if custom_model_type.nil?
    raise ArgumentError, "Custom model #{as} is not associated with the object to which you try to add it." if send(custom_model_type.parameterized_name).nil?
    item = send(custom_model_type.parameterized_name).find { |c| c.id.to_s == fragment['id'].to_s && fragment['id'].present? }
    if fragment['_destroy'] == '1'
      send(custom_model_type.parameterized_name).delete(item)
      return skip!
    end
    item ? item : send(custom_model_type.parameterized_name).append(custom_model_type.customizations.build)
  end.freeze

  class << self
    def decorate(configuration)
      Class.new(self) do
        configuration.each do |custom_model_name, fields|
          property_options = fields.delete(:property_options)
          custom_model_type = CustomModelType.with_parameterized_name(custom_model_name)
          @@mapping_hash ||= {}
          @@mapping_hash[custom_model_name] = fields.deep_dup
          add_validation(custom_model_name, fields)
          collection :"#{custom_model_name}",
                     form: CustomizationForm.decorate(fields),
                     populator: POPULATOR,
                     prepopulator: ->(_options) { prepopulate_customization(property_options, custom_model_type) }

          # used by cocoon gem to create nested forms
          define_method("build_#{custom_model_name}") do
            cmt = CustomModelType.with_parameterized_name(custom_model_name)
            raise "Couldn't find Custom Model Type with name: #{CustomModelType.with_parameterized_name(custom_model_name)}. Valid names are: #{CustomModelType.pluck(:parameterized_name).join(', ')}" if cmt.nil?
            CustomizationForm.decorate(@@mapping_hash[custom_model_name].deep_dup)
                             .new(cmt.customizations.build).tap(&:prepopulate!)
          end
        end

        def prepopulate_customization(property_options, custom_model_type)
          build_quantity = (property_options && property_options[:prepopulate]).to_i
          return unless build_quantity.positive?
          built_objects = []
          build_quantity.times do
            built_objects << custom_model_type.customizations.build
          end
          public_send("#{custom_model_type.parameterized_name}=", built_objects)
        end
      end
    end
  end
end
