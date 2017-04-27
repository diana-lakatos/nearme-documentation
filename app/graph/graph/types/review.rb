# frozen_string_literal: true
module Graph
  module Types
    Review = GraphQL::ObjectType.define do
      name 'Review'
      global_id_field :id

      field :id, !types.Int
      field :comment, !types.String
      field :rating, !types.Int
      field :created_at, !types.String

      field :lister, !Types::User do
        resolve ->(obj, _arg, ctx) { Resolvers::User.new.call(nil, { id: obj.seller_id }, ctx) }
      end
      field :enquirer, !Types::User do
        resolve ->(obj, _arg, ctx) { Resolvers::User.new.call(nil, { id: obj.buyer_id }, ctx) }
      end
    end
  end
end
