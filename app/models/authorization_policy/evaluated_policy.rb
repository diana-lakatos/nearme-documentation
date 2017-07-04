# frozen_string_literal: true
class AuthorizationPolicy
  class EvaluatedPolicy
    def initialize(policy:, user:, object: nil, params: {})
      @user = user
      @policy = policy
      @object = object
      @params = params
    end

    def to_s
      LiquidTemplateParser.new.parse(@policy, current_user: @user, object: @object, params: @params).strip
    end
  end
end
