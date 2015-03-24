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

  def extra_properties_with_labels
    @product.extra_properties.collect do |property|
      [@product.extra_properties.labels[property.first], property.last]
    end
  end

  def product_type
    @product.product_type
  end

  def photo_url
    if photo = @product.images.first
      photo.image.url(:space_listing)
    else
      Placeholder.new(height: 254, width: 405).path
    end
  end
end
