# frozen_string_literal: true
module Graph
  module Resolvers
    class User
      def call(_, args, ctx)
        query = { term: { slug: args[:slug] } } if args[:slug]
        query = { term: { _id: args[:id] } } if args[:id]

        Graph::Resolvers::UserEs.new(query: query, ctx: ctx)
                                .fetch
                                .first
      end

      def self.find_model(user)
        case user
        when ActiveRecord::Base
          user
        when Elastic::UserDrop
          ::User.find(user.id)
        else
          raise NotImplementedError, "User class #{user.class.name} not supported. Valid classes: ::User, Elastic::UserDrop"
        end
      end
    end
  end
end
