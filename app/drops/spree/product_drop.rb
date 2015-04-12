class Spree::ProductDrop < BaseDrop

  attr_reader :product
  delegate :id, :name, :extra_properties, :product_type, :company, to: :product

  def initialize(product)
    @product = product.decorate
  end

  def price
    @product.humanized_price
  end

  def product_url
    urlify(routes.product_path(@product))
  end

  def display_price
    @product.display_price.to_s
  end

  def product_path
    routes.product_path(@product)
  end

  def url
    routes.product_path(@product)
  end

  def photo_url
    @product.images.first.try(:image_url, :space_listing).presence || image_url(Placeholder.new(height: 254, width: 405).path).to_s
  end
end

