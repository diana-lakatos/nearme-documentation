# frozen_string_literal: true
module Deliveries
  class Base
    attr_accessor :logger
    def predefined_packages
      []
    end
  end
end
