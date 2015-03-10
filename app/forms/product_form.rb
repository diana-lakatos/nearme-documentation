class ProductForm < Form

  attr_accessor :all_shipping_categories, :document_requirements, :upload_obligation

  attr_reader :product

  validates :name, presence: true, length: {minimum: 3}
  validates :price, presence: true, numericality: { greater_than: 0 }, unless: lambda { |f| @product.action_rfq? }
  validates :quantity, numericality: { only_integer: true }, presence: true
  validate :validate_images
  validates_presence_of :weight, :if => :shippo_enabled
  validates_presence_of :depth, :if => :shippo_enabled
  validates_presence_of :width, :if => :shippo_enabled
  validates_presence_of :height, :if => :shippo_enabled
  validates_presence_of :shipping_category_id, :unless => :shippo_enabled
  validate :label_and_description_cannot_be_empty
  validate do
    product.valid?
  end

  validate :label_and_description_cannot_be_empty

  def_delegators :@product, :id, :price, :price=, :name, :name=, :description, :id=, :description=,
    :shippo_enabled=, :shippo_enabled, :possible_manual_payment, :possible_manual_payment=, :action_rfq, :action_rfq=, :draft?, :draft=, :draft, :extra_properties, :extra_properties=

  def_delegators :'@product.master', :weight_unit, :weight_unit=, :height_unit, :height_unit=,
    :width_unit, :width_unit=, :depth_unit, :depth_unit=,
    :unit_of_measure, :unit_of_measure=

  def shipping_category_id=(id)
    shipping_category = @company.shipping_categories.where(:id => id).first
    shipping_category = Spree::ShippingCategory.where(:user_id => @company.creator_id, :id => id).first if shipping_category.blank?

    if shipping_category.present?
      @product.shipping_category = shipping_category
      @shipping_category_id = id
      @shipping_category = shipping_category
    end
  end

  def shipping_category_id
    @shipping_category_id
  end

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

  def initialize(product, options={})
    @product = product
    @company = @product.company
    @user = @product.user

    @all_shipping_categories = []
    @all_shipping_categories = @company.shipping_categories.where(:company_default => false) if @company.present? && !@company.new_record?
    @all_shipping_categories = Spree::ShippingCategory.where(:user_id => @user.id, :company_default => false) if @all_shipping_categories.blank? && @user.present?
    if @product.shipping_category.present?
      @shipping_category = @product.shipping_category
      @shipping_category_id = @shipping_category.id
    end

    @upload_obligation = @product.upload_obligation || @product.build_upload_obligation(level: UploadObligation::LEVELS.first)
    @stock_location = @company.stock_locations.first || @company.stock_locations.build(propagate_all_variants: false, name: "Default")
    @stock_item = @stock_location.stock_items.where(variant_id: @product.master.id).first || @stock_location.stock_items.build(backorderable: false)
    @stock_item.variant = @product.master
    @stock_movement = @stock_item.stock_movements.build stock_item: @stock_item
    @document_requirements = [] unless PlatformContext.current.instance.documents_upload_enabled?
  end

  def submit(params)
    store_attributes(params)

    if shippo_enabled
      self.product.shipping_category = get_or_create_default_category_for_company(@company)
      @shipping_category = self.product.shipping_category
    end

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
    @shipping_category.try(:save!, validate: !draft?)
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

  def assign_all_attributes
    @category = @product.taxons.map(&:id).join(",")
    @price = @product.price
    build_document_requirements if PlatformContext.current.instance.documents_upload_enabled?
  end

  private

  def get_or_create_default_category_for_company(company)
    default_category = company.shipping_categories.where(:company_default => true).first
    if default_category.blank?
      default_category = Spree::ShippingCategory.new
      default_category.name = "Default - #{SecureRandom.hex}"
      default_category.company_id = company.id
      default_category.company_default = true
      default_category.save!
    end

    default_category
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
