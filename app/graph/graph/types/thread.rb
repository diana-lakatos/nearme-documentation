# frozen_string_literal: true
module Graph
  module Types
    Thread = GraphQL::ObjectType.define do
      name 'Thread'
      description 'A conversation thread'

      global_id_field :id

      field :id, !types.ID
      field :is_read, types.Boolean
      field :participant, Types::User do
        resolve ->(obj, _arg, ctx) { Resolvers::User.new.call(nil, {id: obj.participant.id }, ctx) }
      end
      field :last_message, Types::Message
      field :messages, types[Types::Message]
      field :url, types.String
    end
  end
end
