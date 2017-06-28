# frozen_string_literal: true
module Graph
  module Resolvers
    class Photos < ActiveRecordCollection
      private

      def main_scope
        ::Photo.not_confidential.order(created_at: :desc)
      end
    end
  end
end
