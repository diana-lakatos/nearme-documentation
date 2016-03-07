class OfferDrop < BaseDrop

  attr_reader :offer

  delegate :slug, :id, :name, :price, to: :offer

  def initialize(offer)
    @offer = offer
  end

  # offer's url
  def url
    routes.offer_url(@offer)
  end

  # offer's path
  def path
    routes.offer_path(@offer)
  end

end
