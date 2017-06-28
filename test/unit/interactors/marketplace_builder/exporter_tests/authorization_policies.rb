# frozen_string_literal: true
require_relative 'basic'
module MarketplaceBuilder
  module ExporterTests
    class AuthorizationPolicies < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        AuthorizationPolicy.create!(instance_id: @instance.id,
                                    name: 'my_authorization_policy',
                                    content: '{% if current_user.first_name == \'Maciek\'%}true{% endif %}')
      end

      def execute!
        liquid_content = read_exported_file('authorization_policies/my_authorization_policy.liquid', :liquid)
        assert_equal liquid_content.body, '{% if current_user.first_name == \'Maciek\'%}true{% endif %}'
        assert_equal liquid_content.name, 'my_authorization_policy'
      end
    end
  end
end
