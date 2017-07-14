require_relative 'basic'

module MarketplaceBuilder
  module ExporterTests
    class ShouldExportCustomModelTypes < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        FactoryGirl.create(:instance_profile_type) unless @instance.reload.default_profile_type.present?
        @model_type = FactoryGirl.create(:custom_model_type, name: 'Vehicles', instance_profile_types: [@instance.default_profile_type])
        FactoryGirl.create(:custom_attribute, name: 'vehicle_type', label: 'Vehicle Type', target: @model_type)
      end

      def execute!
        yaml_content = read_exported_file('custom_model_types/vehicles.yml')
        assert_equal yaml_content['name'], 'Vehicles'
        assert_same_elements yaml_content['custom_attributes'], [
          { 'name' => 'vehicle_type', 'attribute_type' => 'string', 'input_html_options' => {}, 'label' => 'Vehicle Type', 'public' => true, 'search_in_query' => false, 'searchable' => false}
        ]
      end
    end
  end
end
