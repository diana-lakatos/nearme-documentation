Spree::Shipment::ManifestItem.class_eval do

  def to_liquid
    Spree::ManifestItemDrop.new(self)
  end

end

