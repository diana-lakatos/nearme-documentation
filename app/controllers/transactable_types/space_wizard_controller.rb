# frozen_string_literal: true
class TransactableTypes::SpaceWizardController < ApplicationController
  layout :dashboard

  include AttachmentsHelper

  skip_before_action :force_fill_in_wizard_form
  before_action :find_transactable_type
  before_action :redirect_to_dashboard_if_registration_completed, only: [:new, :list]
  before_action :redirect_to_dashboard_if_started_other_listing, only: [:new, :list]
  before_action :set_form_components
  before_action :set_common_variables, only: [:list, :submit_listing]
  before_action :sanitize_price_parameters, only: [:submit_listing]
  before_action :set_theme, only: [:list, :submit_item]

  layout :dashboard_or_community_layout

  def new
    flash.keep(:warning)
    if current_user
      redirect_to transactable_type_space_wizard_list_path(@transactable_type)
    else
      redirect_to new_user_registration_url(wizard: 'space', return_to: transactable_type_space_wizard_list_url(@transactable_type))
    end
  end

  def list
    build_objects
    @transactable.try(:initialize_action_types)
    @transactable.try(:initialize_default_availability_template)
    build_approval_requests
    @photos = (@user.first_listing.try(:photos) || []) + @user.photos.where(owner_id: nil)
    @attachments = (@user.first_listing.try(:attachments) || []) + @user.attachments.where(assetable_id: nil)
  end

  def submit_listing
    if platform_context.instance.skip_company?
      params[:user][:companies_attributes] ||= {}
      params[:user][:companies_attributes]['0'] ||= {}
      params[:user][:companies_attributes]['0'][:name] ||= current_user.first_name
      @user.company_name ||= params[:user][:companies_attributes]['0'][:name]
    end

    set_listing_draft_timestamp(params[:save_as_draft] ? Time.zone.now : nil)
    @user.get_seller_profile
    @user.skip_validations_for = [:buyer]
    @user.must_have_verified_phone_number = true if @user.requires_mobile_number_verifications?
    @user.assign_attributes(wizard_params)

    @user.companies.first.try(:creator=, current_user)
    build_objects
    build_approval_requests
    @user.first_listing.try(:creator=, @user)
    @transactable.try(:initialize_action_types) unless params[:save_as_draft]
    if params[:save_as_draft]
      remove_approval_requests
      @user.valid? # Send .valid? message to object to trigger any validation callbacks
      @user.companies.first.update_metadata(draft_at: Time.now, completed_at: nil)
      if @user.first_listing.nil? || @user.first_listing.new_record?
        @user.save(validate: false)
        fix_action_types
        fix_availability_templates
        WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::DraftCreated, @user.first_listing.try(:id), as: current_user)
      else
        @user.save(validate: false)
      end
      respond_to do |format|
        format.html do
          flash[:success] = t('flash_messages.space_wizard.draft_saved')
          redirect_to transactable_type_space_wizard_list_path(@transactable_type)
        end
        format.json { render json: nil, status: :ok }
      end
    elsif @user.save
      @user.listings.first.try(:action_type).try(:schedule).try(:create_schedule_from_schedule_rules)
      @user.companies.first.update_metadata(draft_at: nil, completed_at: Time.now)
      if @transactable_type.require_transactable_during_onboarding?
        WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::PendingApproval, @user.first_listing.try(:id), as: current_user) unless @user.first_listing.try(:is_trusted?)
        WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::Created, @user.first_listing.try(:id), as: current_user)
      else
        @user.seller_profile.mark_as_onboarded!
      end
      flash[:success] = t('flash_messages.space_wizard.space_listed', bookable_noun: @transactable_type.translated_bookable_noun)
      flash[:error] = t('manage.listings.no_trust_explanation') if @user.listings.first.present? && !@user.listings.first.is_trusted?
      if session[:user_to_be_invited].present?
        user = User.find(session[:user_to_be_invited])
        path = profile_path(user.slug)
        flash[:warning] = t('flash_messages.manage.listings.want_to_see_profile', path: path, name: user.first_name)
        session[:user_to_be_invited] = nil
      end
      redirect_to params[:return_to].presence || dashboard_company_transactable_type_transactables_path(@transactable_type)
    else
      @photos = @user.first_listing ? @user.first_listing.photos : nil
      @attachments = @user.first_listing ? @user.first_listing.attachments : nil

      @global_errors = filter_error_messages(ErrorFilter.new(@user.errors).filter.full_messages)

      render :list
    end
  end

  private

  # When saving drafts we end up with action_type = nil even though it was set from the before_validation callback, causing problems down the line
  def fix_action_types
    listing = @user.companies.first.locations.first.listings.first
    return if listing.nil?
    enabled_action_type = listing.action_types.find(&:enabled)
    if enabled_action_type.present?
      listing.action_type = enabled_action_type
      listing.save(validate: false)
    end
  end

  # When saving drafts we end up with parent_type = nil for custom availability templates causing problems down the line
  def fix_availability_templates
    listing = @user.companies.first.locations.first.listings.first
    return if listing.nil?
    return unless listing.time_based_booking
    availability_template = listing.time_based_booking.availability_template
    if availability_template
      if availability_template.try(:parent_type) == 'Transactable::TimeBasedBooking' && availability_template.try(:parent_id).nil?
        availability_template.parent = listing.time_based_booking
        availability_template.save(validate: false)
      end
    else
      listing.time_based_booking.update(availability_template: @transactable_type.default_availability_template)
    end
  end

  def remove_approval_requests
    @user.approval_requests = []
    @user.companies.first.approval_requests = []
    @user.companies.first.locations.first.listings.first.approval_requests = []
  end

  def filter_error_messages(messages)
    pattern_to_remove = /^Companies locations listings photos|^Companies locations listings availability template availability rules (base )?/
    pattern_listings = /^Companies locations listings/
    # Transformation
    messages = messages.collect do |message|
      if message.to_s.match(pattern_to_remove)
        message.to_s.gsub(pattern_to_remove, '').humanize
      elsif message.to_s.match(pattern_listings)
        message.to_s.gsub(pattern_listings, @transactable_type.translated_bookable_noun).humanize
      else
        message
      end
    end
    # Rejection
    messages = messages.reject do |message|
      message.to_s.match(/latitude|longitude/i)
    end

    messages
  end

  def find_transactable_type
    @transactable_type = TransactableType.includes(:custom_attributes).friendly.find(params[:transactable_type_id])
  end

  def set_form_components
    @form_components = @transactable_type.form_components.where(form_type: FormComponent::SPACE_WIZARD).rank(:rank)
  end

  def set_common_variables
    redirect_to(transactable_type_new_space_wizard_url(@transactable_type)) && return unless current_user.present?

    # preload associations to correcty make #assign_attributes work correctly
    @user = User.includes(companies: :locations).find(current_user.id)
    @company = @user.companies.first
    @country = if params[:user] && params[:user][:country_name]
                 params[:user][:country_name]
               elsif @user.country_name.present?
                 @user.country_name
               else
                 begin
                   request.location.country
                 rescue
                   nil
                 end
               end
  end

  def build_objects
    @user.companies.build if @user.companies.first.nil?
    @user.companies.first.locations.build if @user.companies.first.locations.first.nil?
    @user.companies.first.locations.first.transactable_type = @transactable_type
    if @transactable_type.require_transactable_during_onboarding?
      @transactable = @user.companies.first.locations.first.listings.first || @user.companies.first.locations.first.listings.build(transactable_type_id: @transactable_type.id)
      @transactable.attachment_ids = attachment_ids_for(@transactable) if params.key?(:attachment_ids)
    end
  end

  def redirect_to_dashboard_if_registration_completed
    if current_user.try(:registration_completed?)
      redirect_to dashboard_company_transactable_type_transactables_path(@transactable_type)
    end
  end

  def set_transactable_type_id
    params[:user][:companies_attributes]['0'][:locations_attributes]['0'][:listings_attributes]['0'][:transactable_type_id] = @transactable_type.id
  end

  def set_listing_draft_timestamp(timestamp)
    params[:user][:companies_attributes]['0'][:locations_attributes]['0'][:listings_attributes]['0'][:draft] = timestamp
    params[:user][:companies_attributes]['0'][:locations_attributes]['0'][:listings_attributes]['0'][:enabled] = true
    if @user.companies.first
      params[:user][:companies_attributes]['0'][:id] ||= @user.companies.first.id
      params[:user][:companies_attributes]['0'][:company_address_attributes][:id] ||= @user.companies.first.company_address.try(:id)
      params[:user][:companies_attributes]['0'][:locations_attributes]['0'][:id] ||= @user.companies.first.locations.first.try(:id)
      params[:user][:companies_attributes]['0'][:locations_attributes]['0'][:listings_attributes]['0'][:id] ||= @user.companies.first.locations.first.listings.first.id
      params[:user][:companies_attributes]['0'][:locations_attributes]['0'][:listings_attributes]['0'][:action_types_attributes][0][:id] ||= @user.companies.first.locations.first.listings.first.action_types_attributes.first.id
    end
  rescue
    nil
  end

  def sanitize_price_parameters
    params[:user][:companies_attributes]['0'][:locations_attributes]['0'][:listings_attributes]['0'].select { |k, _v| k.include?('_price') }.each do |k, v|
      params[:user][:companies_attributes]['0'][:locations_attributes]['0'][:listings_attributes]['0'][k] = v.to_f unless v.blank?
    end
  rescue
  end

  def wizard_params
    params.require(:user).permit(secured_params.user(transactable_type: @transactable_type)).tap do |whitelisted|
      begin
        (whitelisted[:seller_profile_attributes][:properties] = params[:user][:seller_profile_attributes][:properties])
      rescue
        {}
      end
      begin
        (whitelisted[:properties] = params[:user][:properties])
      rescue
        {}
      end
      begin
        (whitelisted[:companies_attributes]['0'][:locations_attributes]['0'][:listings_attributes]['0'][:properties] = params[:user][:companies_attributes]['0'][:locations_attributes]['0'][:listings_attributes]['0'][:properties])
      rescue
        {}
      end
    end
  end

  def build_approval_requests
    build_approval_request_for_object(@user)
    build_approval_request_for_object(@user.companies.first)
    if @transactable_type.require_transactable_during_onboarding?
      build_approval_request_for_object(@user.companies.first.locations.first.listings.first)
    end
  end

  def can_delete_photo?(photo, user)
    return true if photo.creator == user # if the user created the photo
    return true if photo.listing.administrator == user # if the user is an admin of the photos content
    return true if user.companies.first.listings.include?(photo.listing) # if the photo content is a listing and belongs to company
  end

  def set_theme
    @theme_name = 'product-theme'
  end

  def redirect_to_dashboard_if_started_other_listing
    listing = current_user.try(:companies).try(:first).try(:locations).try(:first).try(:listings).try(:first)
    if listing.present? && listing.transactable_type_id != @transactable_type.id
      flash[:warning] = t('flash_messages.space_wizard.finish_other_first', wanted_create_noun: @transactable_type.translated_bookable_noun, already_started_noun: listing.transactable_type.translated_bookable_noun)
      redirect_to transactable_type_new_space_wizard_path(listing.transactable_type)
    end
  end
end
