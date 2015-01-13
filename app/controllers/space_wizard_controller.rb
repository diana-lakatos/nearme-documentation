class SpaceWizardController < ApplicationController

  before_filter :find_transactable_type
  before_filter :redirect_to_dashboard_if_user_has_listings, :only => [:new, :list]
  before_filter :set_common_variables, :only => [:list, :submit_listing]
  before_filter :sanitize_price_parameters, :only => [:submit_listing]
  before_filter :set_theme, :only => [:list, :submit_item]

  def new
    flash.keep(:warning)
    event_tracker.clicked_list_your_bookable({source: request.referer ? URI(request.referer).path : "direct"})
    if current_user
      redirect_to space_wizard_list_url
    else
      redirect_to new_user_registration_url(:wizard => 'space', :return_to => space_wizard_list_path)
    end
  end

  def list
    if buyable?
      @boarding_form = BoardingForm.new(current_user)
      @boarding_form.assign_all_attributes
      render :list_item, layout: "dashboard"
    else
      build_objects
      build_approval_requests
      @photos = @user.first_listing ? @user.first_listing.photos : nil
      @user.phone_required = true
      event_tracker.viewed_list_your_bookable
      event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
    end
  end

  def submit_listing
    @user.phone_required = true
    params[:user][:companies_attributes]["0"][:name] = current_user.name if platform_context.instance.skip_company? && params[:user][:companies_attributes]["0"][:name].blank?
    set_listing_draft_timestamp(params[:save_as_draft] ? Time.zone.now : nil)
    @user.assign_attributes(wizard_params)
    @user.companies.first.try(:locations).try(:first).try {|l| l.name_and_description_required = true} unless buyable?
    @user.companies.first.creator_id = current_user.id
    @user.verify_associated = @user.companies.first.verify_associated = !@user.companies.first.new_record? if buyable?
    build_objects
    build_approval_requests
    if params[:save_as_draft]
      remove_approval_requests
      @user.valid? # Send .valid? message to object to trigger any validation callbacks
      @user.save(:validate => false)
      track_saved_draft_event
      PostActionMailer.enqueue_later(24.hours).list_draft(@user)
      flash[:success] = t('flash_messages.space_wizard.draft_saved')
      redirect_to :list
    elsif @user.save
      track_new_space_event
      track_new_company_event
      PostActionMailer.enqueue.list(@user)
      if buyable?
        redirect_to dashboard_products_path
      else
        flash[:success] = t('flash_messages.space_wizard.space_listed', bookable_noun: platform_context.decorate.bookable_noun)
        redirect_to dashboard_transactable_type_transactables_path(@transactable_type)
      end
    else
      @photos = @user.first_listing ? @user.first_listing.photos : nil
      flash.now[:error] = t('flash_messages.space_wizard.complete_fields') + view_context.array_to_unordered_list(@user.errors.full_messages)
      render :list
    end
  end

  def submit_item
    redirect_to(new_space_wizard_url) && return unless current_user.present?

    @boarding_form = BoardingForm.new(current_user)
    if @boarding_form.submit(boarding_form_params)
      redirect_to space_wizard_list_url, notice: t('flash_messages.space_wizard.item_listed', bookable_noun: platform_context.decorate.bookable_noun)
    else
      render :list_item, layout: "dashboard"
    end

  end

  def destroy_photo
    @photo = Photo.find(params[:id])
    if can_delete_photo?(@photo, current_user) && @photo.destroy
      render :text => { success: true, id: @photo.id }, :content_type => 'text/plain'
    else
      render :text => { :errors => @photo.errors.full_messages }, :status => 422, :content_type => 'text/plain'
    end
  end

  private

  def can_delete_photo?(photo, user)
    return true if photo.creator == user                         # if the user created the photo
    return true if photo.listing.administrator == user    # if the user is an admin of the photos content
    return true if @company.listings.include?(photo.listing)     # if the photo content is a listing and belongs to company
  end

  def set_common_variables
    redirect_to(new_space_wizard_url) && return unless current_user.present?

    @user = current_user
    @company = @user.companies.first
    @country = if params[:user] && params[:user][:country_name]
                 params[:user][:country_name]
               elsif @user.country_name.present?
                 @user.country_name
               else
                 request.location.country rescue nil
               end
  end

  def build_objects
    @user.companies.build if @user.companies.first.nil?    
    @user.companies.first.locations.build if @user.companies.first.locations.first.nil?
    @user.companies.first.locations.first.listings.build({:transactable_type_id => @transactable_type.id}) if @user.companies.first.locations.first.listings.first.nil?
  end

  def redirect_to_dashboard_if_user_has_listings
    return if buyable?
    if current_user && current_user.companies.count > 0 && !current_user.has_draft_listings
      redirect_to dashboard_transactable_type_transactables_path(@transactable_type)
    end
  end

  def track_saved_draft_event
    event_tracker.saved_a_draft
  end

  def track_new_space_event
    @location = @user.locations.first
    @listing = @user.listings.first
    event_tracker.created_a_location(@location , { via: 'wizard' })
    event_tracker.created_a_listing(@listing, { via: 'wizard' })
    event_tracker.updated_profile_information(@user)
  end

  def track_new_company_event
    @company = @user.companies.first
    event_tracker.created_a_company(@company) unless platform_context.instance.skip_company?
  end

  def set_transactable_type_id
    params[:user][:companies_attributes]["0"][:locations_attributes]["0"][:listings_attributes]["0"][:transactable_type_id] = TransactableType.first.id
  end

  def set_listing_draft_timestamp(timestamp)
    begin
      params[:user][:companies_attributes]["0"][:locations_attributes]["0"][:listings_attributes]["0"][:draft] = timestamp
      params[:user][:companies_attributes]["0"][:locations_attributes]["0"][:listings_attributes]["0"][:enabled] = true
    rescue
      nil
    end
  end

  def sanitize_price_parameters
    begin
      params[:user][:companies_attributes]["0"][:locations_attributes]["0"][:listings_attributes]["0"].select { |k, v| k.include?('_price') }.each do |k, v|
        params[:user][:companies_attributes]["0"][:locations_attributes]["0"][:listings_attributes]["0"][k] = v.to_f unless v.blank?
      end
    rescue
      # no need to do anything
    end
  end

  def find_transactable_type
    @transactable_type = TransactableType.includes(:custom_attributes).try(:first)
  end

  def wizard_params
    params.require(:user).permit(secured_params.user)
  end

  def boarding_form_params
    params.require(:boarding_form).permit(secured_params.boarding_form)
  end

  def build_approval_requests
    build_approval_request_for_object(@user)
    build_approval_request_for_object(@user.companies.first)
    build_approval_request_for_object(@user.companies.first.locations.first)
    build_approval_request_for_object(@user.companies.first.locations.first.listings.first)
  end

  def remove_approval_requests
    @user.approval_requests = []
    @user.companies.first.approval_requests = []
    @user.companies.first.locations.first.approval_requests = []
    @user.companies.first.locations.first.listings.first.approval_requests = []
  end

  def set_theme
    @theme_name = 'product-theme'
  end
end

