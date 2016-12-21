# frozen_string_literal: true
require 'sendle_api'

# TODO: rename module name
module Deliveries
  def self.courier(name:, settings:, logger: default_logger)
    case name
    when 'sendle' then Sendle.new(settings: settings, logger: logger)
    else
      raise ArgumentError, 'courier not supported yet'
    end
  end

  def self.default_logger
    RequestLogger.new(context: nil)
  end
end
