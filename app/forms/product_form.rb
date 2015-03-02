class ProductForm < Form

  attr_accessor :shipping_methods, :document_requirements, :upload_obligation
  attr_reader :product

  validates :name, presence: true, length: {minimum: 3}
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :quantity, numericality: { only_integer: true }, presence: true
  validate :validate_images, :validate_shipping_methods
  validates_presence_of :weight, :if => :shippo_enabled
  validates_presence_of :depth, :if => :shippo_enabled
  validates_presence_of :width, :if => :shippo_enabled
  validates_presence_of :height, :if => :shippo_enabled
  validate :list_of_countries_or_states_cannot_be_empty
  validate :label_and_description_cannot_be_empty
  validate do
    product.valid?
  end

  validate :label_and_description_cannot_be_empty

  def_delegators :@product, :id, :price, :price=, :name, :name=, :description, :id=, :description=,
    :shippo_enabled=, :shippo_enabled, :action_rfq, :action_rfq=, :draft?, :draft=, :draft, :extra_properties, :extra_properties=

  def_delegators :'@product.master', :weight_unit, :weight_unit=, :height_unit, :height_unit=,
    :width_unit, :width_unit=, :depth_unit, :depth_unit=,
    :unit_of_measure, :unit_of_measure=

  def weight=(value)
    @product.master.weight_user = value
  end

  def weight
    @product.master.weight_user
  end

  def width=(value)
    @product.master.width_user = value
  end

  def width
    @product.master.width_user
  end

  def height=(value)
    @product.master.height_user = value
  end

  def height
    @product.master.height_user
  end

  def depth=(value)
    @product.master.depth_user = value
  end

  def depth
    @product.master.depth_user
  end

  def list_of_countries_or_states_cannot_be_empty
    added_to_base = false
    if !@product.try(:shippo_enabled).present? && self.try(:shipping_methods).present?
      self.shipping_methods.each do |shipping_method|
        if shipping_method.try(:zones).present?
          shipping_method.zones.each do |zone|
            if zone.members.empty?
              if !added_to_base
                # We add this to prevent the form from being saved
                self.errors.add(:base, :zone_incomplete)
                added_to_base = true
              end
              # And we add this to get the error message in the form
              zone.errors.add(:kind, :members_missing)
            end
          end
        end
      end
    end
  end

  def label_and_description_cannot_be_empty
    if @document_requirements.present?
      @document_requirements.each do |document_requirement|
        [:label, :description].each do |field|
          if document_requirement.try(field).empty?
            self.errors.add(:base, "#{field}_empty".to_sym)
            document_requirement.errors.add(field.to_sym, :empty)
          end
        end
      end
    end
  end

  def quantity
    @quantity ||= @stock_item.stock_movements.sum(:quantity)
  end

  def quantity=new_quantity
    @stock_item.stock_movements.build stock_item: @stock_item, quantity: new_quantity.to_i - quantity
    @quantity = new_quantity.to_i
  end

  def taxon_ids
    @product.taxon_ids.join(",")
  end

  def taxon_ids=(taxon_ids)
    @product.taxon_ids = taxon_ids.split(",")
  end

  def image_ids=(image_ids)
    existing_images = @product.images.map(&:id)
    Spree::Image.where(id: (image_ids.reject { |id| existing_images.include?(id) })).each do |i|
      @product.images << i
    end
  end

  def validate_images
    @product.errors.add(:images) unless @product.images.map(&:valid?).all?
  end

  def validate_shipping_methods
    if !@product.shippo_enabled?
      errors.add(:shipping_methods) if @shipping_methods.blank? || !@shipping_methods.map(&:valid?).all?
    end
  end

  def initialize(product, options={})
    @product = product
    @company = @product.company
    @user = @product.user
    @upload_obligation = @product.upload_obligation || @product.build_upload_obligation(level: UploadObligation::LEVELS.first)
    @shipping_category = @product.shipping_category || @product.build_shipping_category(name: 'Default')
    @product.shipping_category = @shipping_category
    @stock_location = @company.stock_locations.first || @company.stock_locations.build(propagate_all_variants: false, name: "Default")
    @stock_item = @stock_location.stock_items.where(variant_id: @product.master.id).first || @stock_location.stock_items.build(backorderable: false)
    @stock_item.variant = @product.master
    @stock_movement = @stock_item.stock_movements.build stock_item: @stock_item
    @document_requirements = [] unless PlatformContext.current.instance.documents_upload_enabled?
  end

  def submit(params)
    store_attributes(params)
    if valid?
      save!
      true
    else
      assign_all_attributes
      false
    end
  end

  def save!(options={})
    @user.save!(validate: !draft?)
    @company.save!(validate: !draft?)
    @product.save!(validate: !draft?)
    @product.images.each { |i| i.save!(validate: false) }
    @product.classifications.each { |x| x.save!(validate: !draft?) }
    @upload_obligation.save!
    @document_requirements.each { |x| x.save! }
    @stock_location.save!(validate: !draft?)
    @stock_item.save!(validate: !draft?)
    @shipping_category.save!(validate: !draft?)
    # We do not touch shipping methods (which are auto-created) if the
    # product is Shippo-enabled

    if !@product.shippo_enabled?
      @shipping_methods.each do |shipping_method|
        shipping_method.save!(validate: !draft?)
        shipping_method.zones.each do |zone|
          zone.company = @company
          zone.save!(validate: !draft?)
          zone.members.each(&:save)
        end
      end
      @company.shipping_methods << @shipping_methods
    end
  end

  def category=(taxon_ids)
    @product.taxon_ids = taxon_ids.split(",")
  end

  def images_attributes=(attributes)
    attributes.each do |key, images_attributes|
      image = @product.images.where(id: images_attributes["id"]).first
      image.try(:update_attribute, :position, images_attributes["position"])
    end
  end

  def document_requirements_attributes=(attributes)
    @document_requirements = []
    attributes.each do |key, document_requirements_attributes|
      next if document_requirements_attributes["hidden"] == "1"
      document_requirement = @product.document_requirements.where(id: document_requirements_attributes["id"]).first
      if document_requirements_attributes["removed"] == "1"
        document_requirement.try(:destroy)
      else
        document_requirement ||= @product.document_requirements.build
        document_requirement.assign_attributes(document_requirements_attributes)
        document_requirement.item = @product
        @document_requirements << document_requirement
      end
    end
  end

  def upload_obligation_attributes=(attributes)
    @upload_obligation.assign_attributes(attributes)
  end

  def shipping_methods_attributes=(attributes)
    @shipping_methods = []
    attributes.each do |key, shipping_methods_attributes|
      next if shipping_methods_attributes["hidden"] == "1"
      shipping_method = @shipping_category.shipping_methods.where(id: shipping_methods_attributes["id"]).first
      if shipping_methods_attributes["removed"] == "1"
        shipping_method.try(:destroy)
      else
        shipping_method ||= Spree::ShippingMethod.new()
        shipping_method.assign_attributes(shipping_methods_attributes)
        shipping_method.shipping_categories = [@shipping_category]
        @shipping_methods << shipping_method
      end
    end
  end

  def assign_all_attributes
    build_shipping_methods
    @category = @product.taxons.map(&:id).join(",")
    @price = @product.price
    build_document_requirements if PlatformContext.current.instance.documents_upload_enabled?
  end

  def build_shipping_methods
    @shipping_methods ||= @shipping_category.shipping_methods.to_a
    5.times do
      hidden = @shipping_methods.blank? && @shipping_category.shipping_methods.blank? ? "0" : "1"
      shipping_method ||= @shipping_category.shipping_methods.build
      shipping_method.hidden = hidden
      shipping_method.calculator ||= Spree::Calculator::Shipping::FlatRate.new(preferred_amount: 0)
      shipping_method.zones.build(kind: "country", name: "Default - #{SecureRandom.hex}")
      @shipping_methods << shipping_method
    end
  end

  def build_document_requirements
    @document_requirements = @product.document_requirements.to_a
    DocumentRequirement::MAX_COUNT.times do
      hidden = @document_requirements.blank? ? "0" : "1"
      document_requirement = @product.document_requirements.build
      document_requirement.hidden = hidden
      @document_requirements << document_requirement
    end
  end
end
