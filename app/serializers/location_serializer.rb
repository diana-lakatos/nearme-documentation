class LocationSerializer < ActiveModel::Serializer
  attributes :id , :name, :description, :email, :phone, :latitude, :longitude, :currency, :location_type_id, :special_notes, :formatted_address, :amenity_ids

  attributes :availability_template_id

  attribute :availability_full_week, :key => :availability_rules_attributes

  has_many :listings, :serializer => ListingWebSerializer

  def availability_template_id
    (!object.availability_template_id.nil?) ? object.availability_template_id : "custom"
  end

  def availability_full_week
     # Return the availability rules as a hash in the same format as the API spec
    object.availability_full_week.map do |d|
      {
          day:d[:day],
          id: d[:rule].id,
          day_name: d[:rule].day_name,
          open_time: d[:rule].open_time,
          close_time: d[:rule].close_time
       }
    end

  end


end
