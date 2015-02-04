# Extracts necessary attributes from objects passed to track_charge

class Analytics::EventTracker::Serializers::TrackChargeSerializer

  def initialize(*objects)
    @objects = objects
  end

  def serialize
    @objects.compact.map { |o| serialize_object(o) }.inject(:merge) || {}
  end

  private

  def serialize_object(object)
    self.class.serialize_object(object)
  end

  def self.serialize_object(object)
    case object
    when Reservation
      {
        amount: object.service_fee_amount_guest.to_f + object.service_fee_amount_host.to_f,
        guest_fee: object.service_fee_amount_guest.to_f,
        host_fee: object.service_fee_amount_host.to_f,
        guest_id: object.owner_id,
        host_id: object.host.try(:id),
        payment_id: object.payments.paid.first.id,
        instance_name: object.instance.name,
        listing_name: object.listing.try(:name),
      }
    when Hash
      object
    else
      raise "Can't serialize #{object}."
    end
  end

end

