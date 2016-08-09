class OfferDrop < OrderDrop

  attr_reader :offer

  def initialize(offer)
    @order = @offer = offer
  end

  def total_units_text
    ''
  end

end
