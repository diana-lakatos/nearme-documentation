collection @locations, :root => false, :object_root => false
  attributes :id, :name, :description, :email, :phone, :latitude, :longitude, :currency, :location_type_id, :special_notes, :formatted_address, :amenity_ids
  node :availability_template_id do |u|
     (!u.availability_template_id.nil?) ? u.availability_template_id : "custom"
  end
  child :listings, :child_root => false do
    attributes :id, :name, :description, :quantity, :confirm_reservations, :location_id, :listing_type_id
    node :defer_availability_rules do |u|
      u.defer_availability_rules? ? 1 : 0
    end
    node :daily_price do |u|
      u.daily_price.cents / 100 if u.daily_price
    end
    node :weekly_price do |u|
      u.weekly_price.cents / 100 if u.weekly_price
    end
    node :monthly_price do |u|
      u.monthly_price.cents / 100 if u.monthly_price
    end

    node :availability_template_id do |u|
       (!u.availability_template_id.nil?) ? u.availability_template_id : "custom"
    end

    child :availability_full_week => :availability_rules_attributes do |u|
      node do |m|
        { :day => m[:day] ,:day_name => m[:rule].day_name, :id => m[:rule].id, :open_time => m[:rule].open_time, :close_time => m[:rule].close_time}
      end
    end
  end

  child :availability_full_week => :availability_rules_attributes do |u|
    node do |m|
      { :day => m[:day] ,:day_name => m[:rule].day_name, :id => m[:rule].id, :open_time => m[:rule].open_time, :close_time => m[:rule].close_time}
    end
  end
