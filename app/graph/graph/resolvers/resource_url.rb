module Graph
  module Resolvers
    class ResourceUrl
      def call(obj, _arg, _ctx)
        Types::ActivityFeed::UrlHelper.new.polymorphic_path(obj)
      end
    end
  end
end
