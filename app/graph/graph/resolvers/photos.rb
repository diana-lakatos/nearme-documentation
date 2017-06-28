# frozen_string_literal: true
module Graph
  module Resolvers
    class Photos < ActiveRecordCollection
      def resolve_by_exclude_ids(relation, ids)
        relation.where.not(id: ids)
      end

      private

      def main_scope
        ::Photo.not_confidential.order(created_at: :desc)
      end
    end
  end
end
