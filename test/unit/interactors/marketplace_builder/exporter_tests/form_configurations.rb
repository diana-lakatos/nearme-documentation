# frozen_string_literal: true
module MarketplaceBuilder
  module ExporterTests
    class ShouldExportFormConfiguration < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        authorization_policy = AuthorizationPolicy.create!(instance_id: @instance.id,
                                                           name: 'form_policy',
                                                           content: '{% if current_user.first_name == \'Maciek\'%}true{% endif %}')
        fc = FormConfiguration.create!(instance_id: @instance.id,
                                       name: 'refer_a_friend',
                                       configuration: configuration,
                                       base_form: 'CustomizationForm',
                                       liquid_body: '<h1>Refer a Friend</h1>')
        fc.update_attribute(:authorization_policy_ids, [authorization_policy.id])
      end

      def execute!
        liquid_content = read_exported_file('form_configurations/refer_a_friend.liquid', :liquid)
        assert_equal liquid_content.body, '<h1>Refer a Friend</h1>'
        assert_equal liquid_content.configuration, 'properties' => { 'enquirer_name' => { 'validation' => { 'presence' => true }, 'lister_name' => { 'validation' => { 'presence' => true } } } }
        assert_equal liquid_content.name, 'refer_a_friend'
        assert_equal liquid_content.base_form, 'CustomizationForm'
        assert_equal liquid_content.authorization_policies, %w(form_policy)
      end

      protected

      def configuration
        {
          'properties' => {
            'enquirer_name' => {
              'validation' => {
                'presence' => true
              },
              'lister_name' => {
                validation: { presence: true }
              }
            }
          }
        }
      end
    end
  end
end
