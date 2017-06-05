module MarketplaceBuilder
  module ExporterTests
    class ShouldExportFormConfiguration < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        FormConfiguration.create!(instance_id: @instance.id,
                                  name: 'refer_a_friend',
                                  configuration: {'properties'=>{'enquirer_name'=>{'validation'=>{'presence'=>true},'lister_name'=>{validation:{presence: true}}}}},
                                  base_form: 'CustomizationForm',
                                  liquid_body: '<h1>Refer a Friend</h1>')
      end

      def execute!
        liquid_content = read_exported_file('form_configurations/refer_a_friend.liquid', :liquid)
        assert_equal liquid_content.body, '<h1>Refer a Friend</h1>'
        assert_equal liquid_content.configuration, {'properties'=>{'enquirer_name'=>{'validation'=>{'presence'=>true},'lister_name'=>{'validation'=>{'presence'=>true}}}}}
        assert_equal liquid_content.name, 'refer_a_friend'
        assert_equal liquid_content.base_form, 'CustomizationForm'
      end
    end
  end
end
