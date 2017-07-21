# frozen_string_literal: true
module Graph
  module Resolvers
    class Order
      def call(_, arguments, _ctx)
        ::Order.find_by(arguments.to_h)
      end
    end
  end
end
