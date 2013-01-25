class ListingSerializer < ApplicationSerializer

  attributes :id, :name, :description, :company_name, :company_description,
             :address, :price, :quantity, :rating

  attribute :latitude,  key: :lat
  attribute :longitude, key: :lon

  has_many :photos
  has_many :amenities, embed: :ids

  # FIXME: for some reason this method is reloading all assocations again?
  def attributes
    hash = super

    # Add score and strict match if present
    hash.merge!(:score => object.score)               unless object.score.nil?
    hash.merge!(:strict_match => object.strict_match) unless object.strict_match.nil?
    hash.merge!(:organizations => [])
    hash
  end

  # Serialize price
  def price
    label = case object.price
    when nil
      'POA'
    when 0
      'Free'
    else
      object.price.format
    end

    {
      amount:        object.price.try(:to_f) || 0.0,
      period:        object.price_period,
      label:         label,
      currency_code: object.price.try(:currency).try(:iso_code) || 'USD'
    }
  end

  # Serialize rating
  def rating
    {
      average: object.rating_average,
      count:   object.rating_count
    }
  end

end
