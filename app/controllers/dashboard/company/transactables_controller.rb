class Dashboard::Company::TransactablesController < Dashboard::Company::BaseController
  include AttachmentsHelper

  before_action :redirect_to_account_if_verification_required
  before_action :find_locations
  before_action :find_transactable_types

  def index
    @transactables = transactables_scope.order(order_param).paginate(page: params[:page], per_page: 20)
    @in_progress_transactables = in_progress_scope.order(order_param).paginate(page: params[:in_progress_page], per_page: 20)
    @archived_transactables = archived_scope.order(order_param).paginate(page: params[:archived_page], per_page: 20)
    @pending_transactables = pending_scope.order(order_param).paginate(page: params[:pending_page], per_page: 20)
  end

  private

  def find_transactable_types
    @transactable_types = TransactableType.where((id = params.try(:[], 'transactable_type_id')).present? ? { id: id } : {})
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
end
