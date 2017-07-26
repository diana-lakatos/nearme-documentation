# frozen_string_literal: true
module NewMarketplaceBuilder
  module Converters
    class ConverterError < StandardError
      attr_reader :details
      def initialize(message, details)
        super(message)
        @details = details
      end
    end

    class BaseConverter
      class << self
        attr_reader :properties_value, :converters, :dynamic_properties, :primary_key_value, :primary_key_options

        def properties(*properties)
          @properties_value = properties
        end

        def property(property_name)
          @dynamic_properties ||= []
          @dynamic_properties.push property_name
        end

        def convert(key_name, option_hash)
          @converters ||= []
          @converters.push name: key_name, options: option_hash
        end

        def primary_key(key, options = {})
          @primary_key_value = key
          @primary_key_options = options
        end
      end

      def initialize(model)
        @model = model
      end

      def find_model_in_scope(scope, model_hash)
        primary_key = primary_key_value
        primary_key_options = self.class.primary_key_options
        find_by_attributes = primary_key_options[:find_by] || [primary_key]

        where_hash = {}
        find_by_attributes.each do |attribute_name|
          where_hash[attribute_name] = model_hash[attribute_name.to_s]
        end
        scope.where(where_hash).first_or_initialize
      end

      def import(model_hash_array)
        model_hash_array.each do |model_hash|
          begin
            model = find_model_in_scope(scope, model_hash)
            model.assign_attributes default_values(model)
            model.assign_attributes model_hash.with_indifferent_access.slice(*properties_value.map(&:to_sym))
            import_dynamic_properties(model, model_hash)

            model.save!

            converters.each do |converter|
              converter[:options][:using].new(model).import(model_hash[converter[:name].to_s]) if model_hash[converter[:name].to_s].present?
            end if converters.present?
          rescue StandardError => error
            puts '########################################################'
            puts "Tried to convert: #{self.class} with #{model.errors.messages}. Error #{error}: #{error.message}"
            raise ConverterError.new error, messages: model.errors.messages, model: model_hash
          end
        end
      end

      def export
        exported_files = []

        scope.each do |model|
          content = {}
          before_serialize(model)

          content = export_basic_properties(model) if properties_value.present?
          content.deep_merge!(export_nested_serializers(model)) if self.class.converters.present?
          content.deep_merge!(export_dynamic_properties(model)) if self.class.dynamic_properties.present?

          p_key = content.slice(primary_key_value.to_s)
          content = p_key.merge(content.except(primary_key_value.to_s).sort.to_h)

          exported_files.push(resource_name: resource_name(model), exported_data: content, model: model)
        end

        exported_files
      end

      def scope
        [@model]
      end

      protected

      def before_serialize(model)
      end

      def default_values(model)
        {}
      end

      private

      def export_basic_properties(model)
        {}.tap do |content|
          properties_value.each do |property|
            value = model.send(property)
            content[property.to_s] = value unless ignored_value?(value)
          end
        end
      end

      def export_nested_serializers(model)
        {}.tap do |content|
          self.class.converters.each do |serializer|
            export_result = serializer[:options][:using].new(model).export
            exported_contents = export_result.map { |exported_hash| exported_hash[:exported_data] }
            content[serializer[:name].to_s] = exported_contents unless ignored_value?(exported_contents)
          end
        end
      end

      def export_dynamic_properties(model)
        {}.tap do |content|
          self.class.dynamic_properties.each do |property_method_name|
            value = send(property_method_name, model)
            content[property_method_name.to_s] = value unless ignored_value?(value)
          end
        end
      end

      def import_dynamic_properties(model, model_hash)
        self.class.dynamic_properties.each do |property_method_name|
          next unless respond_to?("set_#{property_method_name}")
          send("set_#{property_method_name}", model, model_hash.with_indifferent_access[property_method_name])
        end if self.class.dynamic_properties.present?
      end

      def resource_name(model)
        model.send(primary_key_value).parameterize('_')
      end

      def ignored_value?(value)
        value.nil? || (value.is_a?(Array) && value.empty?)
      end

      def converters
        self.class.converters
      end

      def properties_value
        self.class.properties_value
      end

      def primary_key_value
        self.class.primary_key_value
      end
    end
  end
end
