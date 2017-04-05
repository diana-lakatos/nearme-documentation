# frozen_string_literal: true
module Graph
  module Resolvers
    class Order
      def call(_, arguments, _ctx)
        ::Order.find(arguments[:id])
      end
    end
  end
end
