collection @locations, :root => false, :object_root => false
  attributes :id, :name, :description, :email, :phone, :latitude, :longitude, :currency, :special_notes, :formatted_address, :amenity_ids, :availability_template_id

  child :listings, :child_root => false do
    attributes :id, :name, :description, :quantity, :availability_template_id, :confirm_reservations, :location_id
    node :daily_price do |u|
      u.daily_price.cents / 100 if u.daily_price
    end
    node :weekly_price do |u|
      u.weekly_price.cents / 100 if u.weekly_price
    end
    node :monthly_price do |u|
      u.monthly_price.cents / 100 if u.monthly_price
    end
end
