# frozen_string_literal: true
module Graph
  module Types
    MessagesConnection = Graph::Types::Message.define_connection do
      name 'MessagesConnection'
      field :totalCount do
        type types.Int
        resolve ->(obj, _args, _ctx) { obj.nodes.count }
      end
    end
  end
end
