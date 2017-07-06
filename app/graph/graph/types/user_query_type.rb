# frozen_string_literal: true
module Graph
  module Types
    UserQueryType = GraphQL::ObjectType.define do
      field :users do
        type !types[Types::User]
        argument :filters, types[Types::UserFilterEnum]
        argument :take, types.Int
        argument :ids, types[types.ID]
        argument :featured, types.Boolean

        resolve Resolvers::Users.new
      end

      field :user do
        type Types::User
        argument :id, types.ID
        argument :slug, types.String
        resolve Resolvers::User.new
      end

      field :current_user do
        type Types::User
        resolve lambda { |_obj, _arg, ctx|
          user_id = ctx[:current_user_id]
          Resolvers::User.new.call(nil, { id: user_id }, ctx) if user_id
        }
      end
    end
  end
end
