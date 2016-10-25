class DeliveryDrop < BaseDrop
  attr_reader :delivery

  delegate :courier, :status, :order_reference, :pickup_date, :tracking_url,
           to: :delivery

  def initialize(delivery)
    @delivery = delivery
  end
end
