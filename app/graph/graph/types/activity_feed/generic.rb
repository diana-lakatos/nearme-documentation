# frozen_string_literal: true
module Graph
  module Types
    module ActivityFeed
      Generic = GraphQL::ObjectType.define do
        interfaces [ActivityFeed::EventSourceInterface]
        name 'ActivityFeedGeneric'
        field :id, types.ID
        field :created_at, types.String
        field :updated_at, types.String
      end
    end
  end
end
