# frozen_string_literal: true
module Graph
  module Types
    module Authentications
      LoginProvidersQueryType = GraphQL::ObjectType.define do
        field :login_providers do
          type types[types.String]
          resolve ->(_obj, _arg, _) { ::Authentication.available_login_providers}
        end
      end
    end
  end
end
