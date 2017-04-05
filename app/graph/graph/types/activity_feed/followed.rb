# frozen_string_literal: true
module Graph
  module Types
    module ActivityFeed
      Followed = GraphQL::ObjectType.define do
        name 'ActivityFeedFollowed'
        field :id, !types.Int
        field :class, !types.String
        field :url, types.String do
          resolve ->(followed, _args, _ctx) {
            case followed
            when ::Transactable
              followed.to_liquid.show_path
            else
              Resolvers::ResourceUrl.new.call(followed)
            end
          }
        end
      end
    end
  end
end
