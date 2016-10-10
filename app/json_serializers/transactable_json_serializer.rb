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
  attribute :path do
    object.decorate.show_path
  end
  attribute :location_name do
    object.location.name
  end
  attribute :action_recurring_booking do
    object.subscription_booking?
  end
  attribute :action_free_booking do
    object.action_free_booking?
  end
  attribute :action_hourly_booking do
    object.action_type.hour_booking?
  end
  attribute :action_daily_booking do
    object.action_type.day_booking?
  end
  attribute :action_weekly_booking do
    object.action_type.pricings_for_types(%w(5_day 7_day)).any?
  end
  attribute :action_monthly_booking do
    object.action_type.pricings_for_types(%w(20_day 30_day)).any?
  end
  attribute :action_subscription_booking do
    object.action_type.subscription_day_booking? || object.action_type.subscription_month_booking?
  end

  attribute :hourly_price_cents do
    object.action_type.price_cents_for('1_hour')
  end
  attribute :daily_price_cents do
    object.action_type.price_cents_for('1_day')
  end
  attribute :weekly_price_cents do
    object.action_type.price_cents_for('5_day') || object.action_type.price_cents_for('7_day')
  end
  attribute :monthly_price_cents do
    object.action_type.price_cents_for('20_day') || object.action_type.price_cents_for('30_day')
  end
  attribute :weekly_subscription_price_cents do
    object.action_type.price_cents_for('7_subscription_day')
  end
  attribute :monthly_subscription_price_cents do
    object.action_type.price_cents_for('1_subscription_month')
  end
  attribute :fixed_price_cents do
    object.action_type.price_cents_for('1_event')
  end
  attribute :photos_metadata
  attribute :properties do
    object.properties.to_liquid
  end

  has_one :location, include_links: false
  has_one :company, include_links: false
  has_one :creator, include_links: false
  has_many :categories, include_links: false
end
