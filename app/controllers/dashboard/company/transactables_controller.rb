class Dashboard::Company::TransactablesController < Dashboard::Company::BaseController

  include AttachmentsHelper

  before_action :redirect_to_account_if_verification_required
  before_action :find_transactable_type
  before_action :find_transactable, except: [:index, :new, :create]
  before_action :find_locations
  before_action :disable_unchecked_prices, only: :update
  before_action :set_form_components
  before_action :redirect_to_edit_if_single_transactable, only: [:index, :new, :create]
  before_action :redirect_to_new_if_single_transactable, only: [:index, :edit, :update]

  def index
    @transactables = @transactable_type.transactables.where(company_id: @company).
      search_by_query([:name, :description], params[:query]).order('created_at DESC').
        paginate(page: params[:page], per_page: 20)
  end

  def new
    @transactable = @transactable_type.transactables.build company: @company
    @transactable.initialize_action_types
    build_approval_request_for_object(@transactable) unless @transactable.is_trusted?
    @photos = current_user.photos.where(owner_id: nil)
    @attachments = current_user.attachments.where(assetable_id: nil)
  end

  def create
    @transactable = @transactable_type.transactables.build(creator: current_user)
    @transactable.assign_attributes(transactable_params)
    # TODO: fix default availability template
    # @transactable.availability_template = @transactable_type.default_availability_template unless transactable_params.has_key? "availability_template_id"
    @transactable.company = @company
    @transactable.location ||= @company.locations.first if @transactable_type.skip_location?
    @transactable.attachment_ids = attachment_ids_for(@transactable)
    build_approval_request_for_object(@transactable) unless @transactable.is_trusted?

    if @transactable.save
      @transactable.action_type.try(:schedule).try(:create_schedule_from_schedule_rules)
      WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::PendingApproval, @transactable.id) unless @transactable.is_trusted?
      flash[:success] = t('flash_messages.manage.listings.desk_added', bookable_noun: @transactable_type.translated_bookable_noun)
      flash[:error] = t('manage.listings.no_trust_explanation') if !@transactable.is_trusted?
      event_tracker.created_a_listing(@transactable, { via: 'dashboard' })
      event_tracker.updated_profile_information(current_user)
      redirect_to dashboard_company_transactable_type_transactables_path(@transactable_type)
    else
      @global_errors = filter_error_messages(@transactable.errors.full_messages)
      @photos = @transactable.photos
      @attachments = @transactable.attachments
      render :new
    end
  end

  def show
    redirect_to action: :edit
  end

  def edit
    @transactable_type.action_types.bookable.each do |tt_action_type|
      @transactable.action_types.where(transactable_type_action_type: tt_action_type).first_or_initialize(
        type: "Transactable::#{tt_action_type.class.name.demodulize}"
      )
    end
    @photos = @transactable.photos
    @attachments = @transactable.attachments
    build_approval_request_for_object(@transactable) unless @transactable.is_trusted?
    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
  end

  def update
    @transactable.currency = transactable_params[:currency] if transactable_params[:currency].present?
    @transactable.attachment_ids = attachment_ids_for(@transactable)
    @transactable.assign_attributes(transactable_params)
    @transactable.action_type = @transactable.action_types.find(&:enabled)
    build_approval_request_for_object(@transactable) unless @transactable.is_trusted?

    respond_to do |format|
      format.html {
        if @transactable.save
          @transactable.action_type.try(:schedule).try(:create_schedule_from_schedule_rules)
          flash[:success] = t('flash_messages.manage.listings.listing_updated')
          unless @transactable.is_trusted?
            flash[:error] = t('manage.listings.no_trust_explanation')
          end
          redirect_to dashboard_company_transactable_type_transactables_path(@transactable_type)
        else
          @global_errors = filter_error_messages(@transactable.errors.full_messages)
          @photos = @transactable.photos
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
    @transactable_type = TransactableType.find(params[:transactable_type_id] || params[:service_type_id])
  end

  def transactable_params
    params.require(:transactable).permit(secured_params.transactable(@transactable_type)).tap do |whitelisted|
      whitelisted[:properties] = params[:transactable][:properties] rescue {}
    end
  end

  def redirect_to_edit_if_single_transactable
    if @transactable_type.single_transactable && @transactable_type.transactables.where(company_id: @company).count > 0
      redirect_to edit_dashboard_company_transactable_type_transactable_path(@transactable_type, @transactable_type.transactables.where(company_id: @company).first)
    end
  end

  def redirect_to_new_if_single_transactable
    if @transactable_type.single_transactable && @transactable_type.transactables.where(company_id: @company).count.zero?
      redirect_to new_dashboard_company_transactable_type_transactable_path(@transactable_type)
    end
  end

  def redirect_to_account_if_verification_required
    if current_user.host_requires_mobile_number_verifications? && !current_user.has_verified_number?
      flash[:warning] = t('flash_messages.manage.listings.phone_number_verification_needed')
      redirect_to edit_registration_path(current_user)
    end
  end

  def filter_error_messages(messages)
    pattern_to_remove = /^Availability template availability rules (base )?/
    # Transformation
    messages = messages.collect do |message|
      if message.to_s.match(pattern_to_remove)
        message.to_s.gsub(pattern_to_remove, '').humanize
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

end
