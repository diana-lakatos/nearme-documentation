# frozen_string_literal: true
module Graph
  module Resolvers
    class Feed
      def self.call(_obj, _args, ctx)
        ActivityFeedService.new(ctx[:current_user].source)
      end
    end
  end
end
