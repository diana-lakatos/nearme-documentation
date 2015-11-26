class ListingWebSerializer < ApplicationSerializer
  root :listing
  attributes :id, :name, :description, :quantity, :confirm_reservations, :location_id, :listing_type_id, :amenity_ids

  attribute :daily_price
  attribute :weekly_price
  attribute :monthly_price
  attribute :availability_template_id
  attribute :availability_full_week, :key => :availability_rules_attributes

  has_many :photos, :key => :photos_attributes

  def daily_price
    object.daily_price_cents / 100 if object.daily_price
  end

  def weekly_price
    object.weekly_price_cents / 100 if object.weekly_price
  end

  def monthly_price
    object.monthly_price_cents / 100 if object.monthly_price
  end

  def availability_template_id
    object.availability_template.try(:id)
  end

  def availability_full_week
    # Return the availability rules as a hash in the same format as the API spec
    # if target_type is not 'Listing' id is for parent Location, and the rules are provided as matching template for the listing
    object.availability_full_week.map do |d|
      {
          days: d[:days],
          id: (d[:rule].target_type == 'Transactable' ? d[:rule].id : nil),
          open_time: d[:rule].open_time,
          close_time: d[:rule].close_time
       }
    end

  end

end
