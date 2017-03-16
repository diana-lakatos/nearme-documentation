# frozen_string_literal: true
module Graph
  module Types
    Message = GraphQL::ObjectType.define do
      name 'Message'
      description 'A message in a thread'

      global_id_field :id

      field :id, !types.Int
      field :body, !types.String
      field :created_at, types.String
      field :url, types.String
      field :attachments, types[Types::File] do
        resolve ->(obj, _, _) { obj.attachments.map(&:file) }
      end
      field :author, !Types::User
    end
  end
end
