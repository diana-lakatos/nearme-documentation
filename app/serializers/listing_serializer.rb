class ListingSerializer < ApplicationSerializer
  PRICE_PERIODS = {
    free: nil,
    day: 'day'
  }.freeze

  attributes :id, :name, :description, :company_name, :company_description, :currency,
             :address, :quantity

  attribute :prices
  attribute :latitude,  key: :lat
  attribute :longitude, key: :lon

  has_many :photos

  # FIXME: for some reason this method is reloading all assocations again?
  def attributes
    hash = super

    hash[:score] = 0
    hash[:strict_match] = true

    # This remains for backwards compatibility for iOS
    hash[:organizations] = []
    hash
  end

  def prices
    object.action_type.available_prices_in_cents
  end
end
