# frozen_string_literal: true
module Graph
  module Types
    Feed = GraphQL::ObjectType.define do
      name 'Feed'
      description 'Activity feed'

      global_id_field :id

      field :id, !types.ID
      field :events, !types[Types::ActivityFeedEvent]
    end
  end
end
