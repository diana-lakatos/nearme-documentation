class BoardingForm < Form

  attr_accessor :product_form, :company, :user, :company_attributes

  def_delegators :@product, :draft?

  # Validations:

  validate :validate_product, :validate_company

  def validate_product
    errors.add(:product_form, "doesn't look like valid product") unless @product_form.valid?
  end

  def validate_company
    errors.add(:company, :invalid) unless @company.valid?
  end

  def validate_user
    errors.add(:user, :invalid) unless @user.valid?
  end

  def initialize(user, product_type)
    @user = user
    @company = @user.companies.first || @user.companies.build(:creator_id => @user.id)
    @product = @company.products.first || @company.products.build(user_id: @user.id, product_type_id: product_type.id)
    @product.user = @user if @product.user.blank?
    @product_form = ProductForm.new(@product)
  end

  def submit(params)
    params[:product_form].merge!(draft: params.delete(:draft).nil? ? false : true)

    store_attributes(params)
    @company.assign_attributes(params[:company_attributes])

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

  def assign_all_attributes
    @store_name = @company.name
    @product_form.assign_all_attributes
  end
end
