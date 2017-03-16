# frozen_string_literal: true
module Graph
  module Types
    Feed = GraphQL::ObjectType.define do
      name 'Feed'
      description 'Activity feed'

      global_id_field :id

      field :id, !types.Int
      field :events, !types[Types::ActivityFeed::Event] do
        resolve ->(feed, _args, _ctx) { feed.events.map(&:decorate) }
      end
      field :events_next_page, types.Int
      field :owner_id, !types.ID
      field :owner_type, !types.String
      field :has_next_page, types.Boolean
    end
  end
end
