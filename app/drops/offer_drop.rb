class OfferDrop < OrderDrop

  attr_reader :offer

  def initialize(offer)
    @order = @offer = offer
  end


  def total_units_text
    ''
  end

  def new_payment_url
    routes.new_dashboard_company_orders_received_payment_path(@offer)
  end

  def offer_cancel_url
    routes.cancel_dashboard_company_orders_received_path(@offer)
  end

end
