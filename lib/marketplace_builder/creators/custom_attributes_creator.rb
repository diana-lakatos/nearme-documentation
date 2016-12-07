# frozen_string_literal: true
module MarketplaceBuilder
  module Creators
    class CustomAttributesCreator < DataCreator
      def execute!
        data = get_data
        return if data.empty?

        MarketplaceBuilder::Logger.info "#{object_class_name} custom attributes:"

        data.keys.each do |object_name|
          MarketplaceBuilder::Logger.log "\t#{object_name}:"
          object = @instance.send(method_name).where(name: object_name).first
          update_custom_attributes_for_object(object, data[object_name])
        end
      end

      protected

      def object_class_name
        raise NotImplementedError
      end

      private

      def method_name
        object_class_name.pluralize.underscore.to_sym
      end

      def file_name
        "#{object_class_name.pluralize.underscore}.yml"
      end

      def source
        File.join('custom_attributes', file_name)
      end

      def update_custom_attributes_for_object(object, attributes)
        attributes ||= {}
        unused_attrs = if attributes.empty?
                         object.custom_attributes
                       else
                         object.custom_attributes.where('name NOT IN (?)', attributes.keys)
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
          attributes.each do |name, attrs|
            create_custom_attribute(object, name, default_attribute_properties.merge(attrs.symbolize_keys))
            MarketplaceBuilder::Logger.log "\t    - #{name}"
          end
        end
      end

      def create_custom_attribute(object, name, hash)
        hash = hash.with_indifferent_access
        custom_attribute = object.custom_attributes.where(name: name).first_or_initialize
        custom_attribute.custom_validators.destroy_all

        custom_attribute.assign_attributes(hash)
        custom_attribute.save!
        custom_attribute.custom_validators.each(&:save!)
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
end
