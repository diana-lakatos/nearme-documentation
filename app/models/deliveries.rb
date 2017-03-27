# frozen_string_literal: true

# TODO: rename module name
module Deliveries
  def self.courier(name:, settings:, logger: default_logger)
    case name
    when 'sendle' then Sendle.new(settings: settings, logger: logger)
    when 'manual' then Manual.new(logger: logger, name: name)
    when 'auspost-manual' then Manual.new(logger: logger, name: name)
    else
      raise ArgumentError, 'courier not supported yet'
    end
  end

  def self.default_logger
    RequestLogger.new(context: nil)
  end
end
