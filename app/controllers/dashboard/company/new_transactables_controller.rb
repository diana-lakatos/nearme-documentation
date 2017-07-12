# frozen_string_literal: true
class Dashboard::Company::NewTransactablesController < Dashboard::Company::BaseController
  include AttachmentsHelper

  before_action :redirect_to_account_if_verification_required
  before_action :find_locations
  before_action :find_transactable_types, only: [:index]
  before_action :find_transactable_type
  before_action :find_transactable, except: [:index, :new, :create]
  before_action :set_form_components, except: [:index, :enable, :disable, :destroy]
  before_action :redirect_to_edit_if_single_transactable, only: [:index, :new, :create]
  before_action :redirect_to_new_if_single_transactable, only: [:index, :edit, :update]
  before_action :controller_scope

  def index
    @transactables = transactables_scope.order(order_param).paginate(page: params[:page], per_page: 20)
    @in_progress_transactables = in_progress_scope.order(order_param).paginate(page: params[:in_progress_page], per_page: 20)
    @archived_transactables = archived_scope.order(order_param).paginate(page: params[:archived_page], per_page: 20)
    @pending_transactables = pending_scope.order(order_param).paginate(page: params[:pending_page], per_page: 20)
  end

  def new
    @form_configuration = FormConfiguration.find_by(id: params[:form_configuration_id] || 448)
    @transactable_form = @form_configuration&.build(@transactable_type.transactables.build(creator: current_user)).tap(&:prepopulate!)
    # @transactable = @transactable_type.transactables.build company: @company
    # @transactable.initialize_action_types
    # @transactable.initialize_default_availability_template
    # build_approval_request_for_object(@transactable) unless @transactable.is_trusted?
    # @photos = current_user.photos.where(owner_id: nil)
    # @attachments = current_user.attachments.where(assetable_id: nil)
  end

  def create
    # @transactable = @transactable_type.transactables.build(creator: current_user)
    # @transactable.assign_attributes(transactable_params)
    # # TODO: fix default availability template
    # # @transactable.availability_template = @transactable_type.default_availability_template unless transactable_params.has_key? "availability_template_id"
    # @transactable.company = @company
    # @transactable.location ||= @company.locations.first if @transactable_type.skip_location?
    # @transactable.attachment_ids = attachment_ids_for(@transactable)
    # build_approval_request_for_object(@transactable) unless @transactable.is_trusted?
    # @transactable.initialize_action_types
    @form_configuration = FormConfiguration.find_by(id: params[:form_configuration_id] || 448)
    @transactable_form = @form_configuration&.build(@transactable_type.transactables.build(creator: current_user))

    if @transactable_form.validate(params[:form].presence || params[:transactable] || {})
      @transactable_form.save
      @transactable = @transactable_form.model
      raise "Create failed due to configuration issue: #{@transactable_form.model.errors.full_messages.join(', ')}" unless @transactable_form.model.persisted?
      # @transactable.action_type.try(:schedule).try(:create_schedule_from_schedule_rules)
      WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::PendingApproval, @transactable.id) unless @transactable.is_trusted?
      if !@transactable.transactable_type.require_transactable_during_onboarding? && current_user.transactables.with_deleted.count == 1
        WorkflowStepJob.perform(WorkflowStep::ListingWorkflow::Created, @transactable.id)
      end
      flash[:success] = t('flash_messages.manage.listings.desk_added', bookable_noun: @transactable_type.translated_bookable_noun)
      flash[:error] = t('manage.listings.no_trust_explanation') unless @transactable.is_trusted?

      # if session[:user_to_be_invited].present?
      #   user = User.find(session[:user_to_be_invited])
      #   path = profile_path(user.slug)
      #   flash[:warning] = t('flash_messages.manage.listings.want_to_see_profile', path: path, name: user.first_name)
      #   session[:user_to_be_invited] = nil
      # end
      redirect_to url_for(controller_scope << 'transactables')
    else
      @transactable_form.sync
      @transactable_form.prepopulate!
      @global_errors = filter_error_messages(ErrorFilter.new(@transactable_form.errors).filter.full_messages)
      # @photos = @transactable.photos
      # @attachments = @transactable.attachments
      render :new
    end
  end

  def edit
    @form_configuration = FormConfiguration.find_by(id: params[:form_configuration_id] || 448)
    @transactable_form = @form_configuration&.build(@transactable).tap(&:prepopulate!)

    # @transactable.initialize_action_types
    # @photos = @transactable.photos
    # @attachments = @transactable.attachments
    # build_approval_request_for_object(@transactable) unless @transactable.is_trusted?
  end

  def show
    redirect_to action: :edit
  end

  def update
    # @transactable.currency = transactable_params[:currency] if transactable_params[:currency].present?
    # @transactable.attachment_ids = attachment_ids_for(@transactable)
    # @transactable.assign_attributes(transactable_params)
    # @transactable.action_type = @transactable.action_types.find(&:enabled)
    # @transactable.initialize_action_types
    # build_approval_request_for_object(@transactable) unless @transactable.is_trusted?
    @form_configuration = FormConfiguration.find_by(id: params[:form_configuration_id] || 448)
    @transactable_form = @form_configuration&.build(@transactable)
    respond_to do |format|
      format.html do

        if @transactable_form.validate(params[:form].presence || params[:transactable] || {})
          @transactable_form.save
          @transactable = @transactable_form.model
          @transactable.action_type.try(:schedule).try(:create_schedule_from_schedule_rules)
          flash[:success] = t('flash_messages.manage.listings.listing_updated')
          flash[:error] = t('manage.listings.no_trust_explanation') unless @transactable.is_trusted?
          redirect_to url_for(controller_scope << 'transactables')
        else
          @transactable_form.sync
          @transactable_form.prepopulate!
          @global_errors = filter_error_messages(@transactable.errors.full_messages)
          # @transactable.initialize_action_types
          # @photos = @transactable.photos
          # @attachments = @transactable.attachments
          render :edit
        end
      end
      format.json do
        if @transactable.save
          render json: { success: true }
        else
          render json: { errors: @transactable.errors.full_messages }, status: 422
        end
      end
    end
  end

  def enable
    if @transactable.enable!
      render json: { success: true }
    else
      render json: { errors: @transactable.errors.full_messages }, status: 422
    end
  end

  def disable
    if @transactable.disable!
      render json: { success: true }
    else
      render json: { errors: @transactable.errors.full_messages }, status: 422
    end
  end

  def destroy
    TransactableDestroyerService.new(@transactable).destroy

    flash[:deleted] = t('flash_messages.manage.listings.listing_deleted')
    redirect_to url_for(controller_scope << 'transactables')
  end

  def cancel
    if @transactable.cancel
      flash[:notice] = t('flash_messages.manage.listings.listing_cancelled')
    else
      flash[:error] = @transactable.errors.full_messages.join(', ')
    end
    redirect_to url_for(controller_scope << 'transactables') + (params[:status] ? "?status=#{params[:status]}" : '')
  end

  private

  def find_locations
    @locations = @company.locations
  end

  def transactable_params
    params.require(:transactable).permit(secured_params.transactable(@transactable_type, @transactable.new_record? || current_user.id == @transactable.creator_id)).tap do |whitelisted|
      whitelisted[:properties] = begin
                                   params[:transactable][:properties]
                                 rescue
                                   {}
                                 end
    end
  end

  def redirect_to_edit_if_single_transactable
    return unless @transactable_type
    if @transactable_type.single_transactable && @transactable_type.transactables.where(company_id: @company).count > 0
      redirect_to edit_dashboard_company_transactable_type_transactable_path(@transactable_type, @transactable_type.transactables.where(company_id: @company).first)
    end
  end

  def redirect_to_new_if_single_transactable
    return unless @transactable_type
    if @transactable_type.single_transactable && @transactable_type.transactables.where(company_id: @company).count.zero?
      redirect_to new_dashboard_company_transactable_type_transactable_path(@transactable_type)
    end
  end

  def find_transactable_type
    return if params[:transactable_type_id].blank?
    @transactable_type = TransactableType.find(params[:transactable_type_id])
  end

  def find_transactable_types
    @transactable_types = TransactableType.where((id = params.try(:[], 'transactable_type_id')).present? ? { id: id } : {})
  end

  def find_transactable
    @transactable = Transactable.where(company_id: @company).find(params[:id])
    @transactable_type ||= @transactable.transactable_type
  rescue ActiveRecord::RecordNotFound
    raise Transactable::NotFound
  end

  def find_locations
    @locations = @company.locations
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

  # This Scope can be overwritten in
  # Dashboard::Company::TransactableTypes::TransactablesController

  def transactables_scope
    # For Litvault we want to show all transactables but we could make a setting
    # and display only approved ones:
    # "AND pc.approved_by_owner_at IS NOT NULL"
    Transactable
      .joins('LEFT JOIN transactable_collaborators pc ON pc.transactable_id = transactables.id AND pc.deleted_at IS NULL')
      .uniq
      .where('transactables.company_id = ? OR transactables.creator_id = ? OR (pc.user_id = ? AND pc.approved_by_user_at IS NOT NULL)', @company.id, current_user.id, current_user.id)
      .where(transactable_type: @transactable_types)
      .search_by_query([:name, :description], params[:query])
      .apply_filter(params[:filter], @transactable_types.map(&:cached_custom_attributes).flatten.uniq)
  end

  def set_form_components
    raise ActiveRecord::RecordNotFound if @transactable_type.blank?
    @form_components = @transactable_type.form_components.where(form_type: FormComponent::TRANSACTABLE_ATTRIBUTES).rank(:rank)
  end

  def in_progress_scope
    transactables_scope.with_state(:in_progress).joins(:line_item_orders).merge(Order.upcoming.confirmed.for_lister_or_enquirer(@company, current_user))
  end

  def pending_scope
    transactables_scope.with_state(:pending)
  end

  def archived_scope
    transactables_scope.without_state(:pending).where.not(id: in_progress_scope.pluck(:id))
  end

  def possible_sorts
    ['created_at desc', 'created_at asc']
  end

  def order_param
    'transactables.' + (possible_sorts.detect { |sort| sort == params[:order_by] }.presence || possible_sorts.first)
  end

  def controller_scope
    @controller_scope ||= %w(dashboard company)
  end
end
