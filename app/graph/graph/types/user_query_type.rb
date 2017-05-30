# frozen_string_literal: true
module Graph
  module Types
    UserQueryType = GraphQL::ObjectType.define do
      field :users do
        type !types[Types::User]
        argument :filters, types[Types::UserFilterEnum]
        argument :take, types.Int
        argument :ids, types[types.ID]

        resolve Resolvers::Users.new
      end

      field :user do
        type Types::User
        argument :id, types.ID
        argument :slug, types.String
        resolve Resolvers::User.new
      end
    end
  end
end
