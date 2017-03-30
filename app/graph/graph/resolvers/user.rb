# frozen_string_literal: true
module Graph
  module Resolvers
    class User
      def call(_, args, ctx)
        query = { term: { slug: args[:slug] } } if args[:slug]
        query = { term: { _id: args[:id] } } if args[:id]

        UserEs.new(query: query, ctx: ctx)
              .fetch
              .first
      end
    end
  end
end
