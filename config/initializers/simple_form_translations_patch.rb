# Monkey patch including translations per transactable type in I18n lookups for
# labels, hints, placeholders and prompts

module SimpleForm
  module Inputs
    class Base
      def translate_from_namespace(namespace, default = '')
        model_names = lookup_model_names.dup
        lookups     = []
        if translation_namespace = @builder.object.try(:translation_namespace)
          lookups << :"#{translation_namespace}.#{namespace}.#{reflection_or_attribute_name}"
        end
        until model_names.empty?
          joined_model_names = model_names.join('.')
          model_names.shift

          lookups << :"simple_form.#{namespace}.#{joined_model_names}.#{lookup_action}.#{reflection_or_attribute_name}"
          lookups << :"simple_form.#{namespace}.#{joined_model_names}.#{reflection_or_attribute_name}"
        end
        lookups << :"simple_form.#{namespace}.defaults.#{lookup_action}.#{reflection_or_attribute_name}"
        lookups << :"simple_form.#{namespace}.defaults.#{reflection_or_attribute_name}"
        lookups << default
        I18n.t(lookups.shift, default: lookups).presence
      end
    end
  end
end
