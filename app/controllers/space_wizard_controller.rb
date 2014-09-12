class SpaceWizardController < ApplicationController

  before_filter :authenticate_user!
  before_filter :redirect_to_dashboard_if_user_has_listings, :only => [:new, :list]
  before_filter :find_transactable_type
  before_filter :find_user, :except => [:new]
  before_filter :find_user_country, :only => [:list, :submit_listing]
  before_filter :sanitize_price_parameters, :only => [:submit_listing]

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
    @company ||= @user.companies.build.locations.build.listings.build({:transactable_type_id => @transactable_type.id})
    @photos = @user.first_listing ? @user.first_listing.photos : nil
    @user.phone_required = true
    event_tracker.viewed_list_your_bookable
    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
  end

  def submit_listing
    @user.phone_required = true
    params[:user][:companies_attributes]["0"][:name] = current_user.name if platform_context.instance.skip_company? && params[:user][:companies_attributes]["0"][:name].blank?
    set_listing_draft_timestamp(params[:save_as_draft] ? Time.zone.now : nil)
    @user.assign_attributes(wizard_params)
    @user.confidential_files.first.try(:'uploader_id=', current_user.id)
    @user.companies.first.try(:locations).try(:first).try {|l| l.name_and_description_required = true} if TransactableType.first.name == "Listing"
    @user.companies.first.creator_id = current_user.id
    if params[:save_as_draft]
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
      flash[:success] = t('flash_messages.space_wizard.space_listed', bookable_noun: platform_context.decorate.bookable_noun)
      redirect_to manage_locations_path
    else
      @photos = @user.first_listing ? @user.first_listing.photos : nil
      flash.now[:error] = t('flash_messages.space_wizard.complete_fields')
      render :list
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

  def find_user
    @user = current_user
    @country = current_user.country_name
    redirect_to new_space_wizard_url unless @user
  end

  def find_company
    @company = current_user.companies.first if current_user.companies.any?
  end

  def find_location
    @location = @company.locations.first if @company && @company.locations.any?
  end

  def find_listing
    @listing = @location.listings.first if @location && @location.listings.any?
  end

  def redirect_to_dashboard_if_user_has_listings
    redirect_to manage_locations_path if current_user && current_user.listings.count > 0 && !current_user.has_draft_listings
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
    rescue
      nil
    end
  end

  def find_user_country
    @country = if params[:user] && params[:user][:country_name]
      params[:user][:country_name]
    elsif @user.country_name.present?
      @user.country_name
    else
      request.location.country rescue nil
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
    @transactable_type = TransactableType.includes(:transactable_type_attributes).first
  end

  def wizard_params
    params.require(:user).permit(secured_params.user)
  end

end
