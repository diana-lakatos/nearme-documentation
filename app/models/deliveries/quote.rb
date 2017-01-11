# frozen_string_literal: true
# TODO: move to sendle namespace or even to the gem
module Deliveries
  class Quote
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
