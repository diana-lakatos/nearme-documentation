# frozen_string_literal: true
module Graph
  module Resolvers
    class Feed
      def self.call(_obj, args, ctx)
        ActivityFeedService.new(ctx[:current_user].source, user_feed: args[:include_user_feed], page: args[:page])
      end
    end
  end
end
