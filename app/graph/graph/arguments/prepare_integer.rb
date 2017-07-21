# frozen_string_literal: true
module Graph
  module Arguments
    class PrepareInteger
      def call(value, _ctx)
        value.to_i
      end
    end
  end
end