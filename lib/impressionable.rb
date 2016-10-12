module Impressionable
  def track_impression(ip_address = nil)
    # deleted objects return false on .persisted?, i.e.
    # location.deleted? # => true
    # location.persisted? # => false
    return unless self.persisted?
    impressions.create(
      ip_address: ip_address
    )
  end
end
