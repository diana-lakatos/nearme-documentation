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

  def self.validator
    DeliveryValidator
  end

  class DeliveryValidator < ActiveModel::Validator
    def validate(record)
      if record.pickup_date
        validate_pickup_date(record)
      else
        record.errors.add :pickup_date, :empty unless record.pickup_date
      end
    end

    private

    def validate_pickup_date(record)
      record.errors.add :pickup_date, :pick_up_only_on_business_days if business_day?(record.pickup_date)
    end

    def business_day?(date)
      date.sunday? || date.saturday?
    end
  end
end
