class Spree::VariantDrop < BaseDrop

  attr_accessor :variant

  delegate :sku, :product, :options_text, to: :variant
  def initialize(variant)
    @variant = variant
  end

end

