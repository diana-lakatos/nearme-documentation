# frozen_string_literal: true
require 'utils/form_components_creator'

module MarketplaceBuilder
  module FormComponentsBuilder
    def update_form_components_for_object(object, component_types)
      MarketplaceBuilder::Logger.log 'Form components'

      component_types.each do |type, components|
        MarketplaceBuilder::Logger.log "\t  - #{type}"
        creator = Utils::BaseComponentCreator.new(object)
        creator.instance_variable_set(:@form_type_class, "FormComponent::#{type}".safe_constantize)
        components.map!(&:symbolize_keys)
        creator.create_components!(components)
      end
    end
  end
end
