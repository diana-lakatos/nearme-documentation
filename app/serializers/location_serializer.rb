class LocationSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :email, :phone, :latitude, :longitude, :location_type_id, :special_notes, :formatted_address, :amenity_ids

  attributes :availability_template_id

  attribute :availability_full_week, key: :availability_rules_attributes

  has_many :listings, class_name: 'Transactable', serializer: ListingWebSerializer

  def availability_template_id
    (!object.availability_template_id.nil?) ? object.availability_template_id : 'custom'
  end

  def availability_full_week
    # Return the availability rules as a hash in the same format as the API spec
    object.availability_full_week.map do |d|
      {
        days: d[:days],
        id: d[:rules].map(&:id),
        open_time: d[:rules].map(&:open_time).min,
        close_time: d[:rules].map(&:close_time).max
      }
    end
  end
end
