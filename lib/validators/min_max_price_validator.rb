# frozen_string_literal: true
class MinMaxPriceValidator < ActiveModel::Validator

  def validate(record)
    validate_min_price(record)
    validate_max_price(record)
  end

  private

  def validate_min_price(record)
    if record.price_cents&. < record.min_price
      record.errors.add(:price_cents, :greater_than_or_equal_to, unit: record.min_price/100, sub_unit: record.min_price,
                        count: record.min_price)
    end
  end

  def validate_max_price(record)
    if record.price_cents&. > record.max_price
      record.errors.add(:price_cents, :less_than_or_equal_to, unit: record.max_price/100, sub_unit: record.max_price,
                        count: record.max_price)
    end
  end
end
