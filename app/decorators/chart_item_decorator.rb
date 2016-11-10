class ChartItemDecorator < Draper::Decorator
  delegate_all

  def sum_by
    case object
    when Payment
      object.total_amount
    when PaymentTransfer
      object.amount
    when Impression
      object.impressions_count.to_i
    when Transactable
      object.listings_count.to_i
    when Order
      1
    end
  end

  def formatted_date
    time = case object
           when Impression
             Time.strptime(object.impression_date.to_s, '%Y-%m-%d')
           when Transactable
             Time.strptime(object.listing_date.to_s, '%Y-%m-%d')
           else
             object.created_at
    end
    I18n.l(time.to_date, format: :day_and_month)
  end
end
