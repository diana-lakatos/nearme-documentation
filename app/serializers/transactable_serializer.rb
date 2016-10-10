class TransactableSerializer < ApplicationSerializer
  PRICE_PERIODS = {
    free: nil,
    day: 'day'
  }

  attributes :id, :name, :description, :company_name, :company_description,
             :address, :price, :quantity

  attribute :latitude,  key: :lat
  attribute :longitude, key: :lon

  has_many :photos
  has_many :amenities, embed: :ids

  # FIXME: for some reason this method is reloading all assocations again?
  def attributes
    hash = super

    hash.merge!(score: 0)
    hash.merge!(strict_match: true)

    # This remains for backwards compatibility for iOS
    hash.merge!(organizations: [])
    hash
  end

  # Serialize price
  def price
    label = if object.action_type.is_free_booking?
              'Free'
            elsif object.action_type.price_for('1_day').nil?
              'Call'
            else
              object.action_type.price_for('1_day').format
            end

    {
      amount:        object.action_type.price_for('1_day').try(:to_f) || 0.0,
      period:        price_period,
      label:         label,
      currency_code: object.action_type.price_for('1_day').try(:currency).try(:iso_code) || 'USD'
    }
  end

  private

  def price_period
    if object.action_free_booking?
      PRICE_PERIODS[:free]
    else
      PRICE_PERIODS[:day]
    end
  end
end
