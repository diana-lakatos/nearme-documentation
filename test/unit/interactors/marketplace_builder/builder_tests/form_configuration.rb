module MarketplaceBuilder
  module BuilderTests
    class ShouldImportFormConfiguration < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
      end

      def execute!
        form_configuration = @instance.form_configurations.first

        assert_equal form_configuration.name, 'refer_a_friend'
        assert_equal form_configuration.base_form, 'CustomizationForm'
        assert_equal form_configuration.workflow_steps.first.name, 'test step'
        assert_equal form_configuration.configuration, {"properties"=>{"enquirer_name"=>{"validation"=>{"presence"=>true}}}}
        assert form_configuration.liquid_body.include?('<h1>Refer a Friend</h1>')
      end
    end
  end
end
