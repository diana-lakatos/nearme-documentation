# frozen_string_literal: true
module Graph
  module Types
    module ActivityFeed
      EventSource = GraphQL::UnionType.define do
        name 'ActivityFeedEventSource'
        possible_types [
          Graph::Types::ActivityFeed::Comment,
          Graph::Types::ActivityFeed::UserStatusUpdate,
          Graph::Types::ActivityFeed::Photo,
          Graph::Types::Transactables::Transactable,
          Graph::Types::ActivityFeed::Generic
        ]
      end
    end
  end
end
