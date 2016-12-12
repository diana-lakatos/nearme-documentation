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

      unless unused_attrs.empty?
        MarketplaceBuilder::Logger.log "\t  Removing unused attributes:"
        unused_attrs.each do |ca|
          MarketplaceBuilder::Logger.log "\t    - #{ca.name}"
          ca.destroy
        end
      end

      unless attributes.empty?
        MarketplaceBuilder::Logger.log "\t  Updating / creating attributes:"
        attributes.each do |attribute|
          attribute = attribute.symbolize_keys
          name = attribute.delete(:name)
          create_custom_attribute(object, name, default_attribute_properties.merge(attribute))
          MarketplaceBuilder::Logger.log "\t    - #{name}"
        end
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
