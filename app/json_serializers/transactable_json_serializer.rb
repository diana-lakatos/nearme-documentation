class TransactableJsonSerializer
  include JSONAPI::Serializer

  attribute :id
  attribute :slug
  attribute :name
  attribute :description
  attribute :latitude
  attribute :longitude
  attribute :company_name
  attribute :currency
  attribute :address
  attribute :postcode
  attribute :street
  attribute :suburb
  attribute :state
  attribute :city
  attribute :country
  attribute :quantity
  attribute :location_name do
    object.location.name
  end
  attribute :action_recurring_booking
  attribute :action_free_booking
  attribute :action_hourly_booking
  attribute :action_daily_booking
  attribute :action_weekly_booking do
    object.weekly_price_cents.to_i.zero?
  end
  attribute :action_monthly_booking do
    object.monthly_price_cents.to_i.zero?
  end
  attribute :action_subscription_booking

  attribute :hourly_price_cents
  attribute :daily_price_cents
  attribute :weekly_price_cents
  attribute :monthly_price_cents
  attribute :weekly_subscription_price_cents
  attribute :monthly_subscription_price_cents
  attribute :fixed_price_cents
  attribute :photos_metadata
  attribute :properties do
    object.properties.to_liquid
  end

  has_one :location, include_links: false
  has_one :company, include_links: false
  has_one :creator, include_links: false
  has_many :categories, include_links: false
end
