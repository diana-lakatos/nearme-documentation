module Deliveries
  class Manual
    class Quote < Deliveries::Quote
      attr_reader :gross, :tax

      def initialize(gross: 0, tax: 0)
        @gross = gross
        @tax   = tax
      end
    end
  end
end
