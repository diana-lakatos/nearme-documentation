class ListingWebSerializer < ApplicationSerializer
  root :listing
  attributes :id, :name, :description, :quantity, :confirm_reservations, :location_id, :amenity_ids

  attribute :prices
  attribute :availability_template_id
  attribute :availability_full_week, key: :availability_rules_attributes

  has_many :photos, key: :photos_attributes

  def prices
    object.action_type.available_prices_in_cents
  end

  def availability_template_id
    object.availability_template.try(:id)
  end

  def availability_full_week
    # Return the availability rules as a hash in the same format as the API spec
    # if target_type is not 'Listing' id is for parent Location, and the rules are provided as matching template for the listing
    object.action_type.availability_full_week.map do |d|
      {
        days: d[:days],
        id: d[:rules].map { |rule| rule.target_type == 'Transactable' ? rule.id : nil },
        open_time: d[:rules].map(&:open_time).min,
        close_time: d[:rules].map(&:close_time).max
      }
    end
  end
end
