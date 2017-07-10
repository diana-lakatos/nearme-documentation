# frozen_string_literal: true
module Graph
  module Types
    Message = GraphQL::ObjectType.define do
      name 'Message'
      description 'A message in a thread'
      implements GraphQL::Relay::Node.interface

      field :id, !types.ID
      field :body, !types.String
      field :created_at, types.String
      field :url, types.String
      field :attachments, types[Types::File] do
        resolve ->(obj, _, _) { obj.attachments.map(&:file) }
      end
      field :author, Types::User do
        resolve ->(obj, _arg, ctx) { Graph::Resolvers::User.new.call(nil, { id: obj.author_id }, ctx) }
      end
      field :recipient, Types::User do
        resolve ->(obj, _arg, ctx) { Graph::Resolvers::User.new.call(nil, { id: obj.thread_recipient_id }, ctx) }
      end

      field :is_archived, !types.Boolean do
        argument :user_id, types.ID
        resolve ->(obj, arg, _) { arg[:user_id] ? obj.archived_for_by_user_id?(arg[:user_id]) : false }
      end
      # field :properties,
    end
  end
end
