# frozen_string_literal: true
module Shippings
  class Quote
    def initialize(response)
      raise response.body.to_s unless response.success?

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
