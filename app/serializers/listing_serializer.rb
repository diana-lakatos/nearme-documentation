class ListingSerializer < ApplicationSerializer

  attributes :id, :name, :description, :company_name, :company_description,
             :address, :price, :quantity, :rating

  attribute :latitude,  :key => :lat
  attribute :longitude, :key => :lon

  has_many :photos
  has_many :amenities, embed: :ids
  has_many :organizations

  # FIXME: for some reason this method is reloading all assocations again?
  def attributes
    hash = super

    # Add score and strict match if present
    hash.merge!(:score => listing.score)               unless listing.score.nil?
    hash.merge!(:strict_match => listing.strict_match) unless listing.strict_match.nil?

    hash
  end

  # Serialize price
  def price
    {
      amount:        object.price.to_f,
      period:        object.price_period,
      label:         (object.price && object.price != 0) ? object.price.format : 'Free',
      currency_code: object.price.currency.iso_code
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
