class ListingSerializer < ApplicationSerializer

  attributes :id, :name, :description, :company_name, :company_description,
             :address, :price, :quantity, :rating, :amenities

  attribute :latitude,  :key => :lat
  attribute :longitude, :key => :lon

  has_many :photos

  def attributes

    hash = super

    # Add score if present
    hash.merge!(:score => listing.score) if listing.score.present?

    hash
  end

  # Serialize price
  def price

    {
      amount:        object.price.to_f,
      label:         object.price.format,
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
