# frozen_string_literal: true
class Dashboard::Company::TransactableTypes::TransactablesController < Dashboard::Company::TransactablesController
  private

  def transactables_scope
    @transactable_type.transactables
                      .joins('LEFT JOIN transactable_collaborators pc ON pc.transactable_id = transactables.id AND pc.deleted_at IS NULL')
                      .uniq
                      .where('transactables.company_id = ? OR transactables.creator_id = ? OR (pc.user_id = ? AND pc.approved_by_owner_at IS NOT NULL AND pc.approved_by_user_at IS NOT NULL)', @company.id, current_user.id, current_user.id)
                      .search_by_query([:name, :description], params[:query])
                      .apply_filter(params[:filter], @transactable_type.cached_custom_attributes)
  end

  def controller_scope
    @controller_scope ||= ['dashboard', 'company', @transactable_type]
  end
end
