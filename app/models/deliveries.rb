# frozen_string_literal: true
require 'sendle_api'

# TODO: rename module name
module Deliveries
  def self.courier(name:, settings:)
    case name
    when 'sendle' then sendle_client(settings)
    else
      raise ArgumentError, 'courier not supported yet'
    end
  end

  def self.sendle_client(cfg)
    Sendle.new(cfg)
  end
end
