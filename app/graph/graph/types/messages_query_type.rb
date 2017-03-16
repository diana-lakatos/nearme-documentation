# frozen_string_literal: true
module Graph
  module Types
    MessagesQueryType = GraphQL::ObjectType.define do
      field :thread do
        type Types::Thread
        argument :id, types.ID
        resolve ->(_obj, args, _ctx) { }
      end
    end
  end
end
