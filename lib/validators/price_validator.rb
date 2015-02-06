class PriceValidator < ActiveModel::Validator
  def validate(record)
    # Make sure free listing does not have price and vice-versa
    if record.action_free_booking? && record.has_price?
      record.errors.add(:action_free_booking, I18n.t('errors.messages.free'))
    elsif !record.action_free_booking? && !record.has_price?
      record.errors.add(:action_free_booking, I18n.t('errors.messages.free_if_zero'))
    end

    #Make sure a free listing does not have the hourly listing bool set
    if record.action_free_booking? && record.action_hourly_booking?
      record.errors.add(:price_type, I18n.t('errors.messages.free_and_hourly'))
    end

    %w(hourly daily weekly monthly).each do |price|
      options = { attributes: "#{price}_price_cents", allow_nil: true, greater_than_or_equal_to: 0, less_than_or_equal_to: TransactableType::MAX_PRICE }
      options.merge!(record.transactable_type.try(:build_validation_rule_for, price) || {})
      ActiveModel::Validations::NumericalityValidator.new(options).validate(record)
    end
  end

  private

  def price_above_max(price)


  end
end
