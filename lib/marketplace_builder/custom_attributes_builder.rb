# frozen_string_literal: true
module MarketplaceBuilder
  module CustomAttributesBuilder
    def update_custom_attributes_for_object(object, attributes)
      attributes ||= {}
      unused_attrs = if attributes.empty?
                       object.custom_attributes
                     else
                       object.custom_attributes.where('name NOT IN (?)', attributes.map { |attr| attr['name'] })
                     end

      unused_attrs.each { |ca| logger.debug "Removing unused custom attribute: #{ca.name}" }
      unused_attrs.destroy_all

      attributes.each do |attribute|
        attribute = attribute.symbolize_keys
        name = attribute.delete(:name)
        create_custom_attribute(object, name, default_attribute_properties.merge(attribute))
        logger.debug "Creating custom attribute: #{name}"
      end
    end

    def create_custom_attribute(object, name, hash)
      hash = hash.with_indifferent_access
      custom_attribute = object.custom_attributes.where(name: name).first_or_initialize
      custom_attribute.assign_attributes(hash)
      custom_attribute.save!
    end

    def default_attribute_properties
      {
        attribute_type: 'string',
        html_tag: 'input',
        public: true,
        searchable: false,
        required: false
      }
    end
  end
end
