module Impressionable

  def track_impression(ip_address = nil)
    self.impressions.create(:ip_address => ip_address)
  end

end
