class PriceValidator < ActiveModel::Validator
  def validate(record)
    # Make sure free listing does not have price and vice-versa
    if record.action_free_booking? && record.has_price?
      record.errors.add(:action_free_booking, I18n.t('errors.messages.free'))
    elsif record.transactable_type.action_free_booking? && !record.action_free_booking? && !record.has_price?
      record.errors.add(:action_free_booking, I18n.t('errors.messages.free_if_zero'))
    end

    #Make sure a free listing does not have the hourly listing bool set
    if record.action_free_booking? && record.action_hourly_booking?
      record.errors.add(:price_type, I18n.t('errors.messages.free_and_hourly'))
    end

    if !record.action_free_booking? && !record.has_price?
      record.errors.add(:price_type, I18n.t('errors.messages.price_cant_be_blank'))
    end

    %w(hourly daily weekly monthly fixed).reject do |price|
      record.send(:"#{price}_price_cents").to_i.zero?
    end.each do |price|
      options = {
        attributes: "#{price}_price",
        allow_nil: true,
        greater_than_or_equal_to: record.transactable_type.send(:"min_#{price}_price").try(:amount).to_f,
        less_than_or_equal_to: max_price(record.transactable_type.send(:"max_#{price}_price").try(:amount).to_f)
      }
      ActiveModel::Validations::NumericalityValidator.new(options).validate(record)
    end
  end

  private

  def max_price(amount)
    amount.zero? ? (TransactableType::MAX_PRICE/100) : amount
  end

end

