class Spree::ManifestItemDrop < BaseDrop
  attr_reader :manifest_item

  # variant
  #   returns the variant of the product to which this manifest item is tied
  delegate :variant, to: :manifest_item

  def initialize(manifest_item)
    @manifest_item = manifest_item
  end

end
