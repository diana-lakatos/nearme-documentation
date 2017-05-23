# frozen_string_literal: true
module Graph
  module Types
    TopicQueryType = GraphQL::ObjectType.define do
      field :topics do
        type !types[Types::Topic]
        argument :filters, types[Types::TopicFilterEnum]
        argument :take, types.Int
        argument :arbitrary_order, types[types.String]

        resolve Graph::Resolvers::Topics.new
      end
    end
  end
end
