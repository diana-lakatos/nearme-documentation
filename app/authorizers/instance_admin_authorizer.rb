class InstanceAdminAuthorizer < Authorizer

  class UnassignedInstanceAdminRoleError < StandardError
  end

  def authorized?(controller)
    raise InstanceAdminAuthorizer::UnassignedInstanceAdminRoleError.new("Instance admin (id=#{instance_admin.id}) has not been assigned any role") if instance_admin_role.nil?
    if controller.to_s == "InstanceAdmin::BaseController"
      controller = "InstanceAdmin::#{first_permission_have_access_to.camelize}Controller"
    end
    instance_admin_role.send(convert_controller_class_to_db_column(controller))
  end

  def first_permission_have_access_to
    InstanceAdminRole::PERMISSIONS.each do |permission|
      return permission.downcase if authorized?("InstanceAdmin::#{permission}Controller".constantize)
    end
    nil
  end

  private

  def convert_controller_class_to_db_column(controller)
    "permission_" + controller.to_s.demodulize.downcase.gsub("controller", "")
  end

end
