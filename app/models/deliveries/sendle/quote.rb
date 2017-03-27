# frozen_string_literal: true

module Deliveries
  class Sendle
    class Quote < Deliveries::Quote
      def initialize(response)
        @body = response.body.first
      end

      def gross
        to_cents @body['quote']['gross']['amount']
      end

      def tax
        to_cents @body['quote']['tax']['amount']
      end

      private

      def to_cents(string)
        string.to_f * 100
      end
    end
  end
end
