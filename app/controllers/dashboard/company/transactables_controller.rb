class Dashboard::Company::TransactablesController < Dashboard::Company::BaseController

  include AttachmentsHelper

  before_filter :find_transactable_type
  before_filter :find_transactable, :except => [:index, :new, :create]
  before_filter :find_locations
  before_filter :disable_unchecked_prices, :only => :update
  before_filter :set_form_components

  def index
    @transactables = @transactable_type.transactables.where(company_id: @company).
      search_by_query([:name, :description], params[:query]).order('created_at DESC').
        paginate(page: params[:page], per_page: 20)
  end

  def new
    @transactable = @transactable_type.transactables.build company: @company, booking_type: @transactable_type.booking_choices.first
    build_approval_request_for_object(@transactable) unless @transactable.is_trusted?
    @photos = current_user.photos.where(owner_id: nil)
    @attachments = current_user.attachments.where(assetable_id: nil)
    build_document_requirements_and_obligation if platform_context.instance.documents_upload_enabled?
  end

  def create
    @transactable = @transactable_type.transactables.build(creator: current_user)
    # Some currencies have different subunit to unit converion rate. If you do Transactable.new(daily_price: 8, currency: 'JPY') it will
    # incorrectly make daily_price_cents = 8 despite 1 - 1 conversiton rate, because currency at the time of doing this is nil, fallbacking
    # to USD with currency rate 100 - 1. So we want to make sure that currency is assigned.
    @transactable.currency = transactable_params[:currency] if transactable_params[:currency].present?
    @transactable.assign_attributes(transactable_params)
    @transactable.company = @company
    @transactable.location ||= @company.locations.first if @transactable_type.skip_location?
    @transactable.attachment_ids = attachment_ids_for(@transactable)

    build_approval_request_for_object(@transactable) unless @transactable.is_trusted?

    if @transactable.save
      @transactable.schedule.try(:create_schedule_from_schedule_rules) if PlatformContext.current.instance.priority_view_path == 'new_ui'
      WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::PendingApproval, @transactable.id) unless @transactable.is_trusted?
      flash[:success] = t('flash_messages.manage.listings.desk_added', bookable_noun: @transactable_type.translated_bookable_noun)
      flash[:error] = t('manage.listings.no_trust_explanation') if !@transactable.is_trusted?
      event_tracker.created_a_listing(@transactable, { via: 'dashboard' })
      event_tracker.updated_profile_information(current_user)
      redirect_to dashboard_company_transactable_type_transactables_path(@transactable_type)
    else
      unless PlatformContext.current.instance.priority_view_path == 'new_ui'
        flash.now[:error] = t('flash_messages.product.complete_fields') + view_context.array_to_unordered_list(@transactable.errors.full_messages)
      end
      @photos = @transactable.photos
      build_document_requirements_and_obligation
      @attachments = @transactable.attachments
      render :new
    end
  end

  def show
    redirect_to action: :edit
  end

  def edit
    @photos = @transactable.photos
    @attachments = @transactable.attachments
    build_approval_request_for_object(@transactable) unless @transactable.is_trusted?
    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
    build_document_requirements_and_obligation if platform_context.instance.documents_upload_enabled?
  end

  def update
    @transactable.currency = transactable_params[:currency] if transactable_params[:currency].present?
    @transactable.attachment_ids = attachment_ids_for(@transactable)
    @transactable.assign_attributes(transactable_params)
    build_approval_request_for_object(@transactable) unless @transactable.is_trusted?

    respond_to do |format|
      format.html {
        if @transactable.save
          @transactable.schedule.try(:create_schedule_from_schedule_rules) if PlatformContext.current.instance.priority_view_path == 'new_ui'
          flash[:success] = t('flash_messages.manage.listings.listing_updated')
          unless @transactable.is_trusted?
            flash[:error] = t('manage.listings.no_trust_explanation')
          end
          redirect_to dashboard_company_transactable_type_transactables_path(@transactable_type)
        else
          unless PlatformContext.current.instance.priority_view_path == 'new_ui'
            flash.now[:error] = t('flash_messages.product.complete_fields') + view_context.array_to_unordered_list(@transactable.errors.full_messages)
          end
          @photos = @transactable.photos
          build_document_requirements_and_obligation
          @attachments = @transactable.attachments
          render :edit
        end
      }
      format.json {
        if @transactable.save
          render :json => { :success => true }
        else
          render :json => { :errors => @transactable.errors.full_messages }, :status => 422
        end
      }
    end
  end

  def enable
    if @transactable.enable!
      render :json => { :success => true }
    else
      render :json => { :errors => @transactable.errors.full_messages }, :status => 422
    end
  end

  def disable
    if @transactable.disable!
      render :json => { :success => true }
    else
      render :json => { :errors => @transactable.errors.full_messages }, :status => 422
    end
  end

  def destroy
    TransactableDestroyerService.new(@transactable, event_tracker, current_user).destroy

    flash[:deleted] = t('flash_messages.manage.listings.listing_deleted')
    redirect_to dashboard_company_transactable_type_transactables_path(@transactable_type)
  end

  private

  def set_form_components
    @form_components = @transactable_type.form_components.where(form_type: FormComponent::TRANSACTABLE_ATTRIBUTES).rank(:rank)
  end

  def find_locations
    @locations = @company.locations
  end

  def find_transactable
    begin
      @transactable = @transactable_type.transactables.where(company_id: @company).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise Transactable::NotFound
    end
  end

  def disable_unchecked_prices
    Transactable::PRICE_TYPES.each do |price|
      if params[:transactable]["#{price}_price"].blank?
        @transactable.send("#{price}_price_cents=", nil) if @transactable.respond_to?("#{price}_price_cents=")
      end
    end
  end

  def find_transactable_type
    @transactable_type = ServiceType.find(params[:transactable_type_id])
  end

  def transactable_params
    params.require(:transactable).permit(secured_params.transactable(@transactable_type)).tap do |whitelisted|
      whitelisted[:properties] = params[:transactable][:properties] rescue {}
    end

  end

  def build_document_requirements_and_obligation
    @transactable.build_upload_obligation(level: UploadObligation::LEVELS.first) unless @transactable.upload_obligation
    DocumentRequirement::MAX_COUNT.times do
      hidden = @transactable.document_requirements.blank? ? "0" : "1"
      document_requirement = @transactable.document_requirements.build
      document_requirement.hidden = hidden
    end
  end
end
