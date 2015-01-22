class Spree::ProductDrop < BaseDrop

  def initialize(product)
    @product = product.decorate
  end

  def name
    @product.name
  end

  def price
    @product.humanized_price
  end

  def product_url
    urlify(routes.product_path(@product))
  end

  def product_path
    routes.product_path(@product)
  end

  def photo_url
    if photo = @product.images.first
      photo.image.url(:space_listing)
    else
      Placeholder.new(height: 254, width: 405).path
    end
  end
end
