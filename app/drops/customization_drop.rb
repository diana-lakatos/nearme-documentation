class CustomizationDrop < BaseDrop

  attr_reader :customization

  delegate :id, :properties, :custom_model_type, to: :customization

  def initialize(customization)
    @customization = customization
  end

  def name
    @customization.custom_model_type.translated_bookable_noun(2)
  end

  def properties_with_labels
    @customization.custom_model_type.custom_attributes.inject({}) do |result, attribute|
      result[attribute.name] = {
        label: I18n.t(attribute.label_key, default: attribute.label),
        value: @customization.properties[attribute.name]
      }
      result
    end
  end

end
