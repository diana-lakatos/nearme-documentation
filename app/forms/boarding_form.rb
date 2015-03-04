class BoardingForm < Form

  attr_accessor :store_name, :company_address, :product_form

  def_delegators :@product, :draft?

  # Validations:

  validates :store_name, presence: true
  validate :validate_company_address, :validate_product

  def validate_company_address
    errors.add(:company_address, "doesn't look like valid company address") unless @company_address.valid?
  end

  def validate_product
    errors.add(:company_address, "doesn't look like valid product") unless @product_form.valid?
  end

  def initialize(user)
    @user = user
    @company = @user.companies.first || @user.companies.build(:creator_id => @user.id)
    @company_address = @company.company_address || @company.build_company_address
    @product = @company.products.first || @company.products.build(user_id: @user.id, product_type: Spree::ProductType.last)
    @product.user = @user if @product.user.blank?
    @product_form = ProductForm.new(@product)
  end

  def submit(params)
    params[:product_form].merge!(draft: params.delete(:draft).nil? ? false : true)

    store_attributes(params)

    @company.name = @store_name

    if draft? || valid?
      @user.save!(validate: !draft?)
      @company.save!(validate: !draft?)
      @product_form.save!(validate: !draft?)

      true
    else
      assign_all_attributes
      false
    end
  end

  def persisted?
    true
  end

  def product_form=(attributes)
    @product_form.store_attributes(attributes)
  end

  def company_address_attributes=(attributes)
    @company_address.assign_attributes(attributes)
  end

  def assign_all_attributes
    @store_name = @company.name
    @product_form.assign_all_attributes
  end
end
