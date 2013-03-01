class ListingWebSerializer < ApplicationSerializer
  root :listing
  attributes :id, :name, :description, :quantity, :confirm_reservations, :location_id, :listing_type_id

  attribute :defer_availability_rules
  attribute :daily_price
  attribute :weekly_price
  attribute :monthly_price
  attribute :availability_template_id
  attribute :availability_full_week, :key => :availability_rules_attributes

  has_many :photos, :key => :photos_attributes

  def defer_availability_rules
    object.defer_availability_rules? ? 1 : 0
  end

  def daily_price
    object.daily_price.cents / 100 if object.daily_price
  end

  def weekly_price
    object.weekly_price.cents / 100 if object.weekly_price
  end

  def monthly_price
    object.monthly_price.cents / 100 if object.monthly_price
  end

  def availability_template_id
     (object.defer_availability_rules?) ? '' : (object.availability_template_id || "custom")
  end

  def availability_full_week
    # Return the availability rules as a hash in the same format as the API spec
    # if target_type is not 'Listing' id is for parent Location, and the rules are provided as matching template for the listing
    object.availability_full_week.map do |d|
      {
          day: d[:day],
          id: (d[:rule].target_type == 'Listing' ? d[:rule].id : nil),
          day_name: d[:rule].day_name,
          open_time: d[:rule].open_time,
          close_time: d[:rule].close_time
       }
    end

  end

end
