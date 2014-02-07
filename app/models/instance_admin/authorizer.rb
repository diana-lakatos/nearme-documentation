class InstanceAdmin::Authorizer

  PERMISSIONS = %w(Analytics Settings Theme Manage)

  def initialize(user, platform_context)
    @user = user
    @platform_context = platform_context
  end

  def instance_admin?
    instance_admin.present?
  end

  def authorized?(controller)
    raise InstanceAdmin::Authorizer::UnassignedInstanceAdminRoleError.new("Instance admin (id=#{instance_admin.id}) has not been assigned any role") if instance_admin_role.nil?
    if controller == "InstanceAdmin"
      controller = first_permission_have_access_to
    end
    instance_admin_role.send(convert_controller_class_to_db_column(controller))
  end

  def first_permission_have_access_to
    PERMISSIONS.each do |permission|
      return permission.downcase if authorized?(permission)
    end
    nil
  end

  private

  def instance_admin
    @instance_admin ||= @platform_context.instance.instance_admins.where('instance_admins.user_id = ?', @user.id).first
  end

  def instance_admin_role
    @instance_admin_role ||= instance_admin.instance_admin_role
  end

  def convert_controller_class_to_db_column(controller)
    "permission_" + controller.downcase
  end
end
