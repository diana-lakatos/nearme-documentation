# frozen_string_literal: true
module Graph
  module Resolvers
    class Feed
      def self.call(_obj, args, _ctx)
        object_types = {
          'User' => ::User
        }.freeze
        object_type = args[:object_type]
        object_id = args[:object_id]
        object = object_types[object_type].find(object_id)
        ActivityFeedService.new(object, user_feed: args[:include_user_feed], page: args[:page])
      end
    end
  end
end
