class PriceValidator < ActiveModel::Validator
  def validate(record)
    unless record.free? || (record.hourly_price_cents.to_f + record.daily_price_cents.to_f + record.weekly_price_cents.to_f + record.monthly_price_cents.to_f > 0)
      record.errors.add("free", :free)
    end
  end
end
