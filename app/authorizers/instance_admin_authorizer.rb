class InstanceAdminAuthorizer < Authorizer
  class UnassignedInstanceAdminRoleError < StandardError; end

  def authorized?(controller)
    return true if @user.admin?
    return unless @user.instance_admin?

    check_instance_admin_role

    if controller == 'AdministratorRestrictedAccess'
      return instance_administrator?
    end

    if controller == 'InstanceAdmin'
      controller = first_permission_have_access_to
    end
    instance_admin_role.send(convert_controller_class_to_db_column(controller))
  end

  def first_permission_have_access_to
    InstanceAdminRole::PERMISSIONS.each do |permission|
      return permission.downcase if authorized?(permission)
    end
    nil
  end

  private

  def instance_administrator?
    instance_admin_role == InstanceAdminRole.administrator_role
  end

  def check_instance_admin_role
    unless instance_admin_role
      fail UnassignedInstanceAdminRoleError,
           "Instance admin (id=#{instance_admin.id}) has not been assigned any role"
    end
  end

  def convert_controller_class_to_db_column(controller)
    'permission_' + controller.to_s.demodulize.downcase.gsub('controller', '').gsub(/manage(\w+)/, '\1')
  end
end
