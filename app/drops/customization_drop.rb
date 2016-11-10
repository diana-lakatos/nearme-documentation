class CustomizationDrop < BaseDrop
  # @return [CustomizationDrop]
  attr_reader :customization

  # @!method id
  #   id of the customization
  #   @return [Integer]
  # @!method properties
  #   @return [Hash] array of properties for the customization
  # @!method custom_model_type
  #   @return [CustomModelTypeDrop]
  delegate :id, :properties, :custom_model_type, to: :customization

  def initialize(customization)
    @customization = customization
  end

  # @return [String] translation key for the customization
  def name
    @customization.custom_model_type.translated_bookable_noun(2)
  end

  # @return [Hash{String=>Hash{Symbol=>String}}] properties for the customization with labels
  #   hash of the form:
  #   { "url_link" => { :label => "URL", :value => "https://vimeo.com/some_video" } }
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
