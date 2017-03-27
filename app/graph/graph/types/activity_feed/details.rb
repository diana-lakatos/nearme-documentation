# frozen_string_literal: true
module Graph
  module Types
    module ActivityFeed
      Details = GraphQL::ObjectType.define do
        name 'ActivityFeedDetails'
        field :image, types.String
        field :text, types.String
      end
    end
  end
end
