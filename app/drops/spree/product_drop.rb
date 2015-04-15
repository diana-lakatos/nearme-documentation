class Spree::ProductDrop < BaseDrop

  attr_reader :product
  delegate :id, :name, :extra_properties, :total_on_hand, :product_type, :company, to: :product

  def initialize(product)
    @product = product.decorate
  end

  def sanitized_product_description
    Sanitizer.sanitze(@product.description)
  end

  def price
    @product.humanized_price
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

  def product_url
    urlify(routes.product_path(@product))
  end

  def photo_url
    @product.images.first.try(:image_url, :space_listing).presence || image_url(Placeholder.new(height: 254, width: 405).path).to_s
  end

  def thumbnail_url
    @product.images.first.try(:image_url, :thumb).presence || image_url(Placeholder.new(height: 96, width: 96).path).to_s
  end

end
