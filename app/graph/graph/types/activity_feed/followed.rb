# frozen_string_literal: true
module Graph
  module Types
    module ActivityFeed
      Followed = GraphQL::ObjectType.define do
        name 'ActivityFeedFollowed'
        field :id, !types.Int
        field :class, !types.String
        field :path, types.String do
          resolve ->(followed, _args, _ctx) {
            case followed
            when Transactable, User
              followed.decorate.show_path
            else
              followed
            end
          }
        end
      end
    end
  end
end
