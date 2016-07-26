class Transactable::OfferAction < Transactable::ActionType
  has_one :pricing, as: :action
  delegate :price, :unit, to: :pricing, allow_nil: true

  validates :pricings, presence: true, if: :enabled?
  validates_associated :pricings, if: :enabled?

end
