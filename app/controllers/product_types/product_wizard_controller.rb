class ProductTypes::ProductWizardController < ApplicationController

  before_filter :authenticate_user!
  before_filter :find_product_type
  before_filter :redirect_to_dashboard_if_registration_completed, only: [:new]
  before_filter :set_form_components
  before_filter :ensure_system_shipping_categories_copied, only: [:new]

  layout "dashboard"

  def new
    @boarding_form = BoardingForm.new(current_user, @product_type)
    @boarding_form.assign_all_attributes
    @images = (@boarding_form.product_form.try(:product).try(:images) || []) + current_user.products_images.where(viewable_id: nil, viewable_type: nil)
  end

  def create
    redirect_to(new_space_wizard_url) && return unless current_user.present?

    @boarding_form = BoardingForm.new(current_user, @product_type)
    @images = @boarding_form.product_form.product.images
    if @boarding_form.submit(boarding_form_params)
      if @boarding_form.draft?
        flash[:notice] = t('flash_messages.space_wizard.draft_saved', bookable_noun: @product_type.name)
        redirect_to action: :new
      else
        redirect_to dashboard_company_product_type_products_path(@product_type), notice: t('flash_messages.space_wizard.item_listed', bookable_noun: @product_type.name)
      end
    else
      flash.now[:error] = t('flash_messages.product.complete_fields')
      flash.now[:error] = t('flash_messages.product.missing_fields_invalid') if @boarding_form.product_form.required_field_missing?
      render :new
    end

  end

  private

  def find_product_type
    @product_type = Spree::ProductType.includes(:custom_attributes).find(params[:product_type_id])
  end

  def set_form_components
    @form_components = @product_type.form_components.where(form_type: FormComponent::PRODUCT_ATTRIBUTES).rank(:rank)
  end


  def redirect_to_dashboard_if_registration_completed
    if current_user.try(:registration_completed?)
      #redirect_to dashboard_company_product_type_products_path(@product_type)
    end
  end

  def boarding_form_params
    params.require(:boarding_form).permit(secured_params.boarding_form(@product_type))
  end

  def can_delete_photo?(photo, user)
    return true if photo.creator == user                         # if the user created the photo
    return true if photo.listing.administrator == user    # if the user is an admin of the photos content
    return true if user.companies.first.listings.include?(photo.listing)     # if the photo content is a listing and belongs to company
  end

end

