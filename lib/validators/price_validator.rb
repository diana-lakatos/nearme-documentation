class PriceValidator < ActiveModel::Validator
  def validate(record)
    if record.free? && record.has_price?
      record.errors.add("free", :free)
    elsif !record.free? && !record.has_price?
      record.errors.add("free", :free)
    end
  end
end
