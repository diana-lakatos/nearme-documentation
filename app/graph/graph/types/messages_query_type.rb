# frozen_string_literal: true
module Graph
  module Types
    MessagesQueryType = GraphQL::ObjectType.define do
      connection :messages, Graph::Types::MessagesConnection, max_page_size: 50 do
        resolve ->(_obj, _args, _ctx) { ::UserMessage.all.order(created_at: :desc) }
      end
    end
  end
end
