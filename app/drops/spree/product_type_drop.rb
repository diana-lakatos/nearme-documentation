class Spree::ProductTypeDrop < BaseDrop

  attr_reader :product_type

  delegate :id, :buyable?, to: :product_type

  def initialize(product_type)
    @product_type = product_type
  end

  def name
    @product_type.name
  end

  def bookable_noun
    name
  end

  def bookable_noun_plural
    name.pluralize
  end

end

