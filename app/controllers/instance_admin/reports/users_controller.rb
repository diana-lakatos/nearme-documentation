class InstanceAdmin::Reports::UsersController < InstanceAdmin::Reports::BaseController
  private

  def set_scopes
    @search_form = InstanceAdmin::UserSearchForm
    @scope_type_class = InstanceProfileType
    @scope_class = User
  end
end
