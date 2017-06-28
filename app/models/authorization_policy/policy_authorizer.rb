# frozen_string_literal: true
class AuthorizationPolicy
  class PolicyAuthorizer
    AUTHORIZED_TEXT = 'true'
    class << self
      def authorized?(result)
        return false unless result
        result.to_s.strip.downcase == AUTHORIZED_TEXT
      end

      def unauthorized?(result)
        !authorized?(result)
      end
    end
  end
end
