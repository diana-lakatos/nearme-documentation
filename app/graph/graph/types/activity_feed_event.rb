# frozen_string_literal: true
module Graph
  module Types
    ActivityFeedEvent = GraphQL::ObjectType.define do
      name 'ActivityFeedEvent'
      description 'Event for a feed'

      global_id_field :id

      field :id, !types.ID
    end
  end
end
