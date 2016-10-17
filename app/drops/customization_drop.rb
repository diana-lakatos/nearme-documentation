class CustomizationDrop < BaseDrop
  # @return [Customization]
  attr_reader :customization

  # @!method id
  #   id of the customization
  #   @return [Integer]
  # @!method properties
  #   array of properties for the customization
  #   @return [CustomAttributes::CollectionProxy]
  # @!method custom_model_type
  #   @return (see Customization#custom_model_type)
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
