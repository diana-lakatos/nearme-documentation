# frozen_string_literal: true
module Graph
  module Resolvers
    class ShoppingCart
      def call(_, arguments, _ctx)
        conditions = {}
        conditions[:id] = arguments[:id]
        conditions[:user_id] = arguments[:user_id] if arguments[:user_id].present?
        scope = ::ShoppingCart.where(conditions)
        scope = scope.where.not(checkout_at: nil) if arguments[:checked_out]
        scope.first
      end
    end
  end
end
