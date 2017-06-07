# frozen_string_literal: true
module Graph
  module Resolvers
    class Comments < ActiveRecordCollection
      private

      def main_scope
        Comment.all.order(created_at: :desc)
      end
    end
  end
end
