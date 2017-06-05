module MarketplaceBuilder
  module ExporterTests
    class ShouldExportFormConfigurationWithoutBody < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        FormConfiguration.create!(instance_id: @instance.id,
                                  name: 'foo_form_configuration',
                                  configuration: {'properties'=>{'enquirer_name'=>'validation'}},
                                  base_form: 'CustomizationForm'
                                 )
      end

      def execute!
        assert_equal '---
name: foo_form_configuration
base_form: CustomizationForm
configuration:
  properties:
    enquirer_name: validation
---
', exported_file('form_configurations/foo_form_configuration.liquid')
        liquid_content = read_exported_file('form_configurations/foo_form_configuration.liquid', :liquid)
        assert_equal liquid_content.configuration, {'properties'=>{'enquirer_name'=>'validation'}}
        assert_equal liquid_content.name, 'foo_form_configuration'
      end
    end
  end
end
