# frozen_string_literal: true
module MarketplaceBuilder
  module BuilderTests
    class ShouldImportFormConfiguration < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
      end

      def execute!
        form_configuration = @instance.form_configurations.first
        assert_equal 'refer_a_friend', form_configuration.name
        assert_equal 'CustomizationForm', form_configuration.base_form
        assert_equal ['test step'], form_configuration.workflow_steps.pluck(:name)
        assert_equal({ 'properties' => { 'enquirer_name' => { 'validation' => { 'presence' => true } } } },
                     form_configuration.configuration)
        assert form_configuration.liquid_body.include?('<h1>Refer a Friend</h1>')
        assert_equal %w(form_policy), form_configuration.authorization_policies.pluck(:name)
        assert_equal %w(some_email_notification), form_configuration.email_notifications.pluck(:name)
        assert_equal %w(api_notification), form_configuration.api_call_notifications.pluck(:name)
        assert_equal %w(some_sms), form_configuration.sms_notifications.pluck(:name)
      end
    end
  end
end
