class Transactable::PaymentAfterWorkBooking < Transactable::ActionType


  #Orders
  def validate_all_dates_available(order)
    unless order.listing.open_on?(order.date, order.first_period.start_minute)
      order.errors.add(:base, I18n.t('reservations_review.errors.does_not_work_on_date'))
    end
  end
end