# frozen_string_literal: true
module Graph
  module Resolvers
    class ResourceUrl
      def call(obj, _arg = nil, _ctx = nil)
        Graph::Types::ActivityFeed::UrlHelper.new.polymorphic_path(obj)
      end
    end
  end
end
