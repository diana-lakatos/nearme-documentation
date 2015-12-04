class Spree::ProductDrop < BaseDrop
  include CategoriesHelper

  attr_reader :product

  # id
  #   numeric identifier for this product
  # name
  #   name of this product
  # extra_properties
  #   object containing the custom properties for this product
  # total_on_hand
  #   total quantity of this product that is available for ordering
  # product_type
  #   the product type (object) to which this particular product belongs
  # company
  #   the company (object) to which the user who has created this product
  #   belongs
  # attachments
  #   array of (seller) attachments for this product
  delegate :id, :name, :extra_properties, :total_on_hand, :product_type, :company, :updated_at, :attachments, to: :product

  def initialize(product)
    @product = product.decorate
  end

  # sanitized product description (with things like disallowed HTML tags removed etc.)
  def sanitized_product_description
    Sanitizer.sanitze(@product.description)
  end

  # price for this product as a string including the currency symbol
  def price
    @product.humanized_price
  end

  # price for this product as a string including the currency symbol
  def display_price
    @product.display_price.to_s
  end

  # url to this product's page in the marketplace (only the path part)
  def product_path
    routes.product_path(@product)
  end

  # url to this product's page in the marketplace (only the path part)
  def url
    routes.product_path(@product)
  end

  # full product url including the host part
  def product_url
    urlify(routes.product_path(@product))
  end

  # url to the image for this product (or a placeholder if the image is missing)
  def photo_url
    @product.images.first.try(:image_url, :space_listing).presence || image_url(Placeholder.new(height: 254, width: 405).path).to_s
  end

  # url to the thumbnail image for this product (or a placeholder if image is missing)
  def thumbnail_url
    image_url(@product.images.first.try(:image_url, :thumb).presence) || image_url(Placeholder.new(height: 96, width: 96).path).to_s
  end

  # returns hash of categories { "<name>" => { "name" => '<translated_name', "children" => [<collection of chosen values] } }
  def categories
    if @categories.nil?
      @categories = build_categories_hash_for_object(@product, @product.product_type.categories.roots.includes(:children))
    end
    @categories
  end

end
