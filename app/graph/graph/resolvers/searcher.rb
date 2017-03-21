# frozen_string_literal: true
module Graph
  module Resolvers
    class Searcher
      def call(_, arguments, ctx)
        @ctx = ctx
        @arguments = arguments
        resolve_by
      end

      def resolve_by
        drop = searcher.to_liquid
        drop.context = liquid_context
        drop
      end

      private

      def current_user
        @ctx[:current_user] && @ctx[:current_user].source
      end

      def liquid_context
        @ctx[:liquid_context]
      end

      def searcher
        InstanceType::Searcher::Elastic::GeolocationSearcher::Listing
          .new(transactable_type, params)
          .tap(&:invoke)
      end

      def params
        @arguments[:params].to_h.symbolize_keys
      end

      def transactable_type
        TransactableType.find_by!(name: @arguments[:kind])
      end
    end
  end
end
