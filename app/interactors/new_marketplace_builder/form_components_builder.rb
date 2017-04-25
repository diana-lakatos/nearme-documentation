# frozen_string_literal: true
require 'utils/form_components_creator'

module NewMarketplaceBuilder
  module FormComponentsBuilder
    def update_form_components_for_object(object, form_components)
      object.form_components.destroy_all

      form_components.each do |component|
        component = component.with_indifferent_access
        form_type_class = "FormComponent::#{component[:type].upcase}".safe_constantize

        creator = Utils::BaseComponentCreator.new(object)
        creator.instance_variable_set(:@form_type_class, form_type_class)
        creator.create_components!([component])
      end
    end

    def whitelisted_form_component_properties
      [:name, :fields]
    end
  end
end
