# frozen_string_literal: true

module Deliveries
  class Quote
    def gross
      raise NotImplementedError
    end

    def tax
      raise NotImplementedError
    end
  end
end
