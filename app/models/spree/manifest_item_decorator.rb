Spree::Shipment::ManifestItem.class_eval do

  def to_liquid
    @spree_manifest_item_drop ||= Spree::ManifestItemDrop.new(self)
  end

end

