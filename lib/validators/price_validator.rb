class PriceValidator < ActiveModel::Validator
  def validate(record)
    # Make sure free listing does not have price and vice-versa
    if record.respond_to?(:free)
      if record.free? && record.has_price?
        record.errors.add("free", :free)
      elsif !record.free? && !record.has_price?
        record.errors.add("free", :free)
      end
    end

    #Make sure a free listing does not have the hourly listing bool set
    if record.respond_to?(:free?) && record.respond_to?(:hourly_reservations?)
      if record.free? && record.hourly_reservations?
        record.errors.add(:price_type, "listing cannot be free and have an hourly rate")
      end
    end
  end
end

