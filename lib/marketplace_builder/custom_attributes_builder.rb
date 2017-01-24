# frozen_string_literal: true
module MarketplaceBuilder
  module CustomAttributesBuilder
    include MarketplaceBuilder::CustomValidatorsBuilder

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

        validator_hash = attribute.delete(:validation) || {}
        validator_hash = validator_hash.first if validator_hash.kind_of?(Array)
        validator_hash = validator_hash.with_indifferent_access

        validator_hash.keys.each do |prop|
          unless validator_properties.include? prop.to_s
            validator_hash.delete(prop)
            logger.error "Removing invalid validator property #{prop} from custom field validator"
          end
        end

        attribute[:valid_values] = validator_hash[:valid_values].presence || []

        custom_attribute = create_custom_attribute(object, name, default_attribute_properties.merge(attribute))
        logger.debug "Creating custom attribute: #{name}"
        create_custom_validator(custom_attribute, name, validator_hash)
      end
    end

    def create_custom_attribute(object, name, hash)
      hash = hash.with_indifferent_access
      custom_attribute = object.custom_attributes.where(name: name).first_or_initialize

      custom_attribute.assign_attributes(hash)
      custom_attribute.save!
      custom_attribute
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

    def whitelisted_properties
      %w(public html_tag label searchable valid_values search_in_query input_html_options)
    end

    def validator_properties
      %w(required regex valid_values max_length min_length validation_only_on_update)
    end
  end
end
