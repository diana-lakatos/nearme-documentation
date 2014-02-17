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
      record.errors.add(:price_type, "listing cannot be free and have an hourly rate")
    end

    #Make sure that prices are not too low and not too high
    if record.instance.present? && !record.free?
      record.class::PRICE_TYPES.each do |price|
        record_price = record.send("#{price}_price")
        next if record_price.nil? || record_price.zero?

        if record.instance.send("min_#{price}_price").present? &&
          record_price < record.instance.send("min_#{price}_price")
          record.errors.add("#{price}_price".to_sym, "#{price.capitalize} price is too low")
        end

        if record.instance.send("max_#{price}_price").present? &&
          record_price > record.instance.send("max_#{price}_price")
          record.errors.add("#{price}_price".to_sym, "#{price.capitalize} price is too high")
        end
      end
    end
  end
end
