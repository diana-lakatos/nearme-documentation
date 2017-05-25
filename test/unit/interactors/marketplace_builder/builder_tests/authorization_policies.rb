# frozen_string_literal: true
module MarketplaceBuilder
  module BuilderTests
    class AuthorizationPolicies < ActiveSupport::TestCase
      def initialize(instance)
        @instance = instance
      end

      def execute!
        authorization_policy = AuthorizationPolicy.where(name: 'my_authorization_policy').first
        assert_equal '{% if current_user.first_name == \'Maciek\'%}true{% endif %}', authorization_policy.content.strip
      end
    end
  end
end
