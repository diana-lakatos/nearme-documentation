class ListingSerializer < ApplicationSerializer
  PRICE_PERIODS = {
    :free => nil,
    :day => 'day'
  }

  attributes :id, :name, :description, :company_name, :company_description,
             :address, :price, :quantity, :rating

  attribute :latitude,  key: :lat
  attribute :longitude, key: :lon

  has_many :photos
  has_many :amenities, embed: :ids

  # FIXME: for some reason this method is reloading all assocations again?
  def attributes
    hash = super

    hash.merge!(:score => 0)
    hash.merge!(:strict_match => true)

    # This remains for backwards compatibility for iOS
    hash.merge!(:organizations => [])
    hash
  end

  # Serialize price
  def price
    label = case object.daily_price
    when nil
      'Call'
    when 0
      'Free'
    else
      object.daily_price.format
    end

    {
      amount:        object.daily_price.try(:to_f) || 0.0,
      period:        price_period,
      label:         label,
      currency_code: object.daily_price.try(:currency).try(:iso_code) || 'USD'
    }
  end

  # Serialize rating
  def rating
    {
      average: object.rating_average,
      count:   object.rating_count
    }
  end

  private

  def price_period
    if object.free?
      PRICE_PERIODS[:free]
    else
      PRICE_PERIODS[:day]
    end
  end

end
