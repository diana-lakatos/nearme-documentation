# frozen_string_literal: true
module Graph
  module Resolvers
    class Searcher
      def call(_, arguments, ctx)
        @ctx = ctx
        resolve_by(arguments)
      end

      def resolve_by(arguments)
        drop = create_searcher(arguments).to_liquid
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

      def create_searcher(arguments)
        result_view = arguments[:result_view]
        transactable_type = TransactableType.find(arguments[:transactable_type_id])
        search_params = arguments[:search_params].to_h.symbolize_keys
        InstanceType::SearcherFactory.new(transactable_type, search_params, result_view, current_user)
                                     .get_searcher
      end

      def search_params
        @arguments[:search_params]
      end

      def page
        search_params[:page]
      end

      def per_page
        search_params[:per_page]
      end
    end
  end
end
