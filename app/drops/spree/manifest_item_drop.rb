class Spree::ManifestItemDrop < BaseDrop
  attr_reader :manifest_item

  delegate :variant, to: :manifest_item

  def initialize(manifest_item)
    @manifest_item = manifest_item
  end

end
