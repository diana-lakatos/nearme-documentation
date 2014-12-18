class BoardingForm < Form

  attr_accessor :store_name
  attr_accessor :item_title, :item_description, :price, :category
  attr_accessor :quantity
  attr_accessor :company_address
  attr_accessor :photos
  attr_accessor :shipping_methods
  attr_accessor :draft
  attr_reader :spree_api_key

  # Validations:

  validates :store_name, presence: true
  validates :item_title, presence: true
  validates :price, presence: true, numericality: true
  validates :quantity, numericality: { only_integer: true }, presence: true
  validate :validate_company_address, :validate_images, :validate_shipping_methods

  def validate_company_address
    errors.add(:company_address, "doesn't look like valid company address") unless @company_address.valid?
  end

  def validate_images
    errors.add(:photos, "doesn't look like valid image") unless @product.images.map(&:valid?).all?
  end

  def validate_shipping_methods
    errors.add(:shipping_methods, "doesn't look like valid shipping method") unless @shipping_methods.map(&:valid?).all?
  end

  def initialize(user)
    @user = user
    @spree_api_key = @user.generate_spree_api_key
    @company = @user.companies.first || @user.companies.build
    @shipping_category = @company.shipping_categories.first || @company.shipping_categories.build(name: 'Default')
    @product = @company.products.first || @company.products.build
    @product.shipping_category = @shipping_category
    @company_address = @company.company_address || @company.build_company_address
    @stock_location = @company.stock_locations.first || @company.stock_locations.build(propagate_all_variants: false, name: "Default")
    @stock_item = @stock_location.stock_items.where(variant_id: @product.master.id).first || @stock_location.stock_items.build(backorderable: false)
    @stock_item.variant = @product.master
    @stock_movement = @stock_item.stock_movements.build stock_item: @stock_item
  end

  def submit(params)
    validate = params[:draft].nil?

    store_attributes(params)

    @company.name = @store_name
    @product.name = @item_title
    @product.description = @item_description
    @product.price = @price
    @stock_movement.quantity = @quantity

    if !validate || valid?
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
      @company_address.save!(validate: validate)

      true
    else
      assign_all_attributes
      false
    end
  end

  def persisted?
    true
  end

  def company_address_attributes=(attributes)
    @company_address.assign_attributes(attributes)
  end

  def photos_attributes=(attributes)
    # This part is going to be changed when switch to image picker
    attributes.each do |key, photo_attributes|
      @product.images.build(photo_attributes) if photo_attributes[:attachment].present?
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
    @store_name = @company.name
    @item_title = @product.name
    @item_description = @product.description
    @category = @product.taxons.map(&:id).join(",")
    @price = @product.price
    @quantity = @stock_item.stock_movements.sum(:quantity)
    @photos = @product.images.to_a
    (3 - @product.images.size).times { @photos << Spree::Image.new }
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
