class Spree::VariantDrop < BaseDrop

  attr_accessor :variant

  # sku
  #   the sku code for this product variant
  # product
  #   the product to which this product variant refers
  # options_text
  #   text describing this particular variant of the product
  delegate :sku, :product, :options_text, to: :variant

  def initialize(variant)
    @variant = variant
  end

end

