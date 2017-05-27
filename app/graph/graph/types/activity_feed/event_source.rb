# frozen_string_literal: true
module Graph
  module Types
    module ActivityFeed
      EventSource = GraphQL::UnionType.define do
        name 'ActivityFeedEventSource'
        possible_types [
          ActivityFeed::Comment,
          ActivityFeed::UserStatusUpdate,
          ActivityFeed::Photo,
          Types::Transactables::Transactable,
          ActivityFeed::Generic
        ]
      end
    end
  end
end
