# frozen_string_literal: true
module Graph
  module Types
    module ActivityFeed
      Photo = GraphQL::ObjectType.define do
        # interfaces [ActivityFeed::EventSourceInterface]
        name 'ActivityFeedPhoto'
        field :id, types.ID
        field :created_at, types.String
        field :updated_at, types.String
        field :image, Types::Image
      end
    end
  end
end
