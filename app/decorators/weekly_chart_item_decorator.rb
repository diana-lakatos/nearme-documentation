class WeeklyChartItemDecorator < Draper::Decorator
  delegate_all

  def sum_by
    case object
    when ReservationCharge
      object.total_amount
    when PaymentTransfer
      object.amount
    end
  end

  def formatted_date
    object.created_at.strftime('%b %d')
  end

end
