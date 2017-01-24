module MarketplaceBuilder::Serializers
  class BaseSerializer
    class << self
      attr_reader :resource_name_function, :properties_value, :serializers, :dynamic_properties

      def resource_name(function)
        @resource_name_function = function
      end

      def properties(*properties)
        @properties_value = properties
      end

      def property(property_name)
        @dynamic_properties ||= []
        @dynamic_properties.push property_name
      end

      def serialize(key_name, option_hash)
        @serializers ||= []
        @serializers.push name: key_name, options: option_hash
      end
    end

    def initialize(model)
      @model = model
    end

    def export
      exported_files = []

      scope.each do |model|
        content = {}

        before_serialize(model) if respond_to?(:before_serialize)

        content = export_basic_properties(model) if self.class.properties_value.present?
        content.deep_merge!(export_nested_serializers(model)) if self.class.serializers.present?
        content.deep_merge!(export_dynamic_properties(model)) if self.class.dynamic_properties.present?

        exported_files.push(resource_name: resource_name(model), exported_data: content)
      end

      exported_files
    end

    def scope
      [@model]
    end

    private

    def export_basic_properties(model)
      {}.tap do |content|
        self.class.properties_value.each do |property|
          value = model.send(property)
          content[property.to_s] = value unless is_ignored_value(value)
        end
      end
    end

    def export_nested_serializers(model)
      {}.tap do |content|
        self.class.serializers.each do |serializer|
          export_result = serializer[:options][:using].new(model).export
          exported_contents = export_result.map{|exported_hash| exported_hash[:exported_data]}
          content[serializer[:name].to_s] = exported_contents unless is_ignored_value(exported_contents)
        end
      end
    end

    def export_dynamic_properties(model)
      {}.tap do |content|
        self.class.dynamic_properties.each do |property_method_name|
          value = self.send(property_method_name, model)
          content[property_method_name.to_s] = value unless is_ignored_value(value)
        end
      end
    end

    def resource_name(model)
      self.class.resource_name_function ? self.class.resource_name_function.call(model) : self.class.name.to_s
    end

    def is_ignored_value(value)
      value.nil? || (value.kind_of?(Array) && value.empty?)
    end
  end
end
