class PriceValidator < ActiveModel::Validator
  def validate(record)
    # Make sure free listing does not have price and vice-versa
    if record.free? && record.has_price?
      record.errors.add("free", :free)
    elsif !record.free? && !record.has_price?
      record.errors.add("free", :free)
    end

    #Make sure a free listing does not have the hourly listing bool set
    if record.free? && record.hourly_reservations?
      record.errors.add(:pricing_type, "listing cannot be free and have an hourly rate")
    end
  end
end
