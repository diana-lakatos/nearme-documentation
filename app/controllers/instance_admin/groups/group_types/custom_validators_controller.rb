class InstanceAdmin::Groups::GroupTypes::CustomValidatorsController < InstanceAdmin::CustomValidatorsController

  protected

  def resource_class
    GroupType
  end

  def redirect_path
    instance_admin_groups_group_type_custom_validators_path
  end

  def find_validatable
    @validatable = GroupType.find(params[:group_type_id])
  end

  def permitting_controller_class
    @controller_scope ||= 'groups'
  end

  def available_attributes
    @attributes = Group.column_names.map{ |column| [column.humanize, column] }
  end

  def set_breadcrumbs
    @breadcrumbs_title = BreadcrumbsList.new(
      { :url => instance_admin_groups_group_types_path, :title => 'Group Type' },
      { :title => @validatable.name.titleize },
      { :url => redirect_path, :title => t('instance_admin.manage.transactable_types.custom_validators') }
    )
  end

end
