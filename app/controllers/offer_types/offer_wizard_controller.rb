class OfferTypes::OfferWizardController < ApplicationController

  before_filter :authenticate_user!
  before_filter :find_offer_type
  before_filter :redirect_to_dashboard_if_registration_completed, only: [:new]
  before_filter :set_common_variables, :only => [:new, :create]
  before_filter :build_objects, only: [:new]
  before_filter :set_form_components

  layout 'dashboard'

  def new
    @photos = (@user.offers.first.try(:photos) || []) + @user.photos.where(owner_id: nil)
    @attachments = (@user.first_listing.try(:attachments) || []) + @user.attachments.where(assetable_id: nil)
    @user.companies.first.offers.build unless @user.companies.first.offers.first
    build_approval_requests
  end

  def create
    @user.assign_attributes(wizard_params)
    company = @user.companies.first
    company.creator = current_user
    offer = company.offers.first
    offer.creator = current_user
    offer.attachment_ids = params[:attachment_ids]
    offer.draft_at = nil
    @user.build_seller_profile(instance_profile_type: current_instance.seller_profile_type) if @user.seller_profile.blank?
    if params[:save_as_draft]
      @user.valid? # Send .valid? message to object to trigger any validation callbacks
      company.update_metadata({draft_at: Time.now, completed_at: nil})
      if offer.new_record?
        offer.draft_at = Time.now
        @user.save(validate: false)
        track_saved_draft_event
        # WorkflowStepJob.perform(WorkflowStep::OfferWorkflow::DraftCreated, offer.id)
      else
        @user.save(validate: false)
      end
      flash[:success] = t('flash_messages.space_wizard.draft_saved')
      redirect_to @offer_type.wizard_path
    elsif @user.save
      company.update_metadata({draft_at: nil, completed_at: Time.now})
      track_new_offer_event(offer)
      track_new_company_event(company)
      flash[:success] = t('flash_messages.space_wizard.space_listed', bookable_noun: @offer_type.name)
      redirect_to dashboard_company_offer_type_offers_path(@offer_type)
    else
      @photos = (@user.offers.first.try(:photos) || []) + @user.photos.where(owner_id: nil)
      @attachments = (@user.first_listing.try(:attachments) || []) + @user.attachments.where(assetable_id: nil)
      flash.now[:error] = t('flash_messages.space_wizard.complete_fields') + view_context.array_to_unordered_list(@user.errors.full_messages)
      render :new
    end

  end

  private

  def build_objects
    company = @user.companies.first_or_initialize
    company.offers.build(offer_type: @offer_type, creator: current_user)
  end

  def find_offer_type
    @offer_type = OfferType.find(params[:offer_type_id])
  end

  def set_form_components
    @form_components = @offer_type.form_components.where(form_type: FormComponent::SPACE_WIZARD).rank(:rank)
  end

  def set_common_variables
    @user = User.includes(:offers).find(current_user.id)
    @country = if params[:user] && params[:user][:country_name]
                 params[:user][:country_name]
               elsif @user.country_name.present?
                 @user.country_name
               else
                 request.location.country rescue nil
               end
  end


  def redirect_to_dashboard_if_registration_completed
    if current_user.try(:registration_completed?)
      redirect_to dashboard_company_offer_type_offers_path(@offer_type)
    end
  end

  def wizard_params
    params.require(:user).permit(secured_params.user(offer_type: @offer_type))
  end

  def track_saved_draft_event
    event_tracker.saved_a_draft
  end

  def track_new_offer_event(offer)
    event_tracker.created_an_offer(offer, { via: 'wizard' })
    event_tracker.updated_profile_information(@user)
  end

  def track_new_company_event(company)
    event_tracker.created_a_company(company) unless platform_context.instance.skip_company?
  end

  def build_approval_requests
    build_approval_request_for_object(@user)
    build_approval_request_for_object(@user.companies.first)
    build_approval_request_for_object(@user.companies.first.offers.first)
  end

end

