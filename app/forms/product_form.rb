class ProductForm < Form

  # attr_accessor :name, :description, :price, :category
  # attr_accessor :quantity
  attr_accessor :images
  attr_accessor :shipping_methods
  attr_accessor :draft
  attr_reader :product

  # Validations:

  validates :name, presence: true
  validates :price, presence: true, numericality: true
  validates :quantity, numericality: { only_integer: true }, presence: true
  validate :validate_images, :validate_shipping_methods

  def_delegators :@product, :price, :price=,  :name, :name=, :description, :description=
  def_delegators :@stock_movement, :quantity=

  def quantity
    @stock_item.stock_movements.sum(:quantity)
  end

  def taxon_ids
    @product.taxon_ids.join(",")
  end

  def taxon_ids=(taxon_ids)
    @product.taxon_ids = taxon_ids.split(",")
  end

  def validate_images
    errors.add(:images) unless @product.images.map(&:valid?).all?
  end

  def validate_shipping_methods
    errors.add(:shipping_methods) if @shipping_methods.blank? || !@shipping_methods.map(&:valid?).all?
  end

  def initialize(product, options={})
    @product = product
    @company = @product.company
    @user = @product.user
    @shipping_category = @product.shipping_category || @product.build_shipping_category(name: 'Default')
    @product.shipping_category = @shipping_category
    @stock_location = @company.stock_locations.first || @company.stock_locations.build(propagate_all_variants: false, name: "Default")
    @stock_item = @stock_location.stock_items.where(variant_id: @product.master.id).first || @stock_location.stock_items.build(backorderable: false)
    @stock_item.variant = @product.master
    @stock_movement = @stock_item.stock_movements.build stock_item: @stock_item
  end

  def submit(params)
    validate = params[:draft].nil?

    store_attributes(params)

    if !validate || valid?
      save!
      true
    else
      assign_all_attributes
      false
    end
  end

  def save!(options={})
    validate = options[:validate]
    @stock_item.stock_movements.build stock_item: @stock_item, quantity: - @stock_item.stock_movements.sum(:quantity)

    @user.save!(validate: validate)
    @company.save!(validate: validate)
    @product.save!(validate: validate)
    @product.images.each { |x| x.save!(validate: validate) }
    @product.classifications.each { |x| x.save!(validate: validate) }
    @stock_location.save!(validate: validate)
    @stock_item.save!(validate: validate)
    @shipping_category.save!(validate: validate)
    @shipping_methods.each do |shipping_method|
      shipping_method.destroy if shipping_method.removed == '1'
      shipping_method.save!(validate: validate)
      shipping_method.zones.each do |zone|
        zone.company = @company
        zone.save!(validate: validate)
        zone.members.each(&:save)
      end
    end
    @company.shipping_methods << @shipping_methods
  end

  def images_attributes=(attributes)
    # This part is going to be changed when switch to image picker
    attributes.each do |key, photo_attributes|
      if photo_attributes[:_destroy] == "1"
        @product.images.where(id: photo_attributes[:id]).first.try(:destroy)
      else
        @product.images.build(remote_image_url: photo_attributes[:remote_image_url]) if photo_attributes[:remote_image_url].present?
      end
    end
  end

  def category=(taxon_ids)
    @product.taxon_ids = taxon_ids.split(",")
  end

  def shipping_methods_attributes=(attributes)
    @shipping_methods = []
    attributes.each do |key, shipping_methods_attributes|
      next if shipping_methods_attributes["hidden"] == "1"
      shipping_method = @shipping_category.shipping_methods.where(id: shipping_methods_attributes["id"]).first
      shipping_method ||= Spree::ShippingMethod.new()
      shipping_method.assign_attributes(shipping_methods_attributes)
      shipping_method.shipping_categories = [@shipping_category]
      @shipping_methods << shipping_method
    end
  end

  def assign_all_attributes
    build_shipping_methods
    @shipping_methods ||= @shipping_category.shipping_methods
    @category = @product.taxons.map(&:id).join(",")
    @price = @product.price
    @images = @product.images.to_a
    (3 - @product.images.size).times { @images << Spree::Image.new(remote_image_url: nil)}
  end

  def build_shipping_methods
    5.times do
      hidden = @shipping_category.shipping_methods.blank? ? "0" : "1"
      shipping_method ||= @shipping_category.shipping_methods.build
      shipping_method.hidden = hidden
      shipping_method.calculator ||= Spree::Calculator::Shipping::FlatRate.new(preferred_amount: 0)
      shipping_method.zones.build(kind: "country", name: "Default - #{SecureRandom.hex}")
    end
  end
end