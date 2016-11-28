# frozen_string_literal: true
class CustomizationsForm < BaseForm
  POPULATOR = lambda do |collection:, index:, **args|
    name_to_custom_model_type_hash ||= {}
    custom_model_type = name_to_custom_model_type_hash[args[:as]] ||= CustomModelType.find_by(name: args[:as])
    if (customization = collection[index]).present?
      customization
    else
      collection.insert(index, custom_model_type.customizations.build)
    end
  end.freeze

  class << self
    def decorate(configuration)
      Class.new(self) do
        configuration.each do |custom_model_name, fields|
          @@mapping_hash ||= {}
          @@mapping_hash[custom_model_name] = fields.dup

          collection :"#{custom_model_name}",
                     form: CustomizationForm.decorate(fields),
                     populator: POPULATOR

          # used by cocoon gem to create nested forms
          define_method("build_#{custom_model_name}") do
            cmt = CustomModelType.find_by(name: custom_model_name)
            raise "Couldn't find Custom Model Type with name: #{custom_model_name}. Valid names are: #{CustomModelType.pluck(:name)}" if cmt.nil?
            CustomizationForm.decorate(@@mapping_hash[custom_model_name]).new(cmt.customizations.build).tap(&:prepopulate!)
          end
        end
      end
    end
  end
end
