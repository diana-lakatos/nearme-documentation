collection @locations, :root => false, :object_root => false
  attributes :id, :name, :description, :email, :phone, :latitude, :longitude, :currency, :location_type_id, :special_notes, :formatted_address, :amenity_ids
  node :availability_template_id do |location|
     (!location.availability_template_id.nil?) ? location.availability_template_id : "custom"
  end

  child :listings, :child_root => false do
    attributes :id, :name, :description, :quantity, :confirm_reservations, :location_id, :listing_type_id
    node :defer_availability_rules do |l|
      l.defer_availability_rules? ? 1 : 0
    end
    node :daily_price do |l|
      l.daily_price.cents / 100 if l.daily_price
    end
    node :weekly_price do |l|
      l.weekly_price.cents / 100 if l.weekly_price
    end
    node :monthly_price do |l|
      l.monthly_price.cents / 100 if l.monthly_price
    end

    node :availability_template_id do |l|
       (l.defer_availability_rules?) ? (l.availability_template_id || '')  : "custom"
    end

    child :availability_full_week => :availability_rules_attributes do |u|
      node do |m|
        if m[:rule].target_type == 'Listing'
          {:id => m[:rule].id}
        end
      end

      node do |m|
          {:day => m[:day] ,:day_name => m[:rule].day_name, :open_time => m[:rule].open_time, :close_time => m[:rule].close_time}
      end
      #node do |m|
        #if m[:rule].target_type == 'Location'
          #{ :day => m[:day] ,:day_name => m[:rule].day_name, :id => nil, :open_time => m[:rule].open_time, :close_time => m[:rule].close_time}
        #else
          #{ :day => m[:day] ,:day_name => m[:rule].day_name, :id => m[:rule].id, :open_time => m[:rule].open_time, :close_time => m[:rule].close_time}
        #end
      #end
    end
  end

  child :availability_full_week => :availability_rules_attributes do |u|
    node do |m|
      { :day => m[:day] ,:day_name => m[:rule].day_name, :id => m[:rule].id, :open_time => m[:rule].open_time, :close_time => m[:rule].close_time}
    end
  end
