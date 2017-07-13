# frozen_string_literal: true
module Graph
  module Resolvers
    class User
      def self.find_model(user)
        case user
        when ActiveRecord::Base
          user
        else
          ::User.find(user.id)
        end
      end

      def call(_, arguments, ctx)
        Graph::Resolvers::Users.new.call(self, arguments, ctx).first
      end
    end
  end
end
