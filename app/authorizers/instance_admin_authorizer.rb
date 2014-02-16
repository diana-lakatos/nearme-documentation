class InstanceAdminAuthorizer < Authorizer

  class UnassignedInstanceAdminRoleError < StandardError; end

  def authorized?(controller)
    raise InstanceAdminAuthorizer::UnassignedInstanceAdminRoleError.new("Instance admin (id=#{instance_admin.id}) has not been assigned any role") if instance_admin_role.nil?
    if controller == "InstanceAdmin"
      controller = first_permission_have_access_to
    end
    instance_admin_role.send(convert_controller_class_to_db_column(controller))
  end

  def first_permission_have_access_to
    instance_admin_role.first_permission_have_access_to
  end

  private

  def convert_controller_class_to_db_column(controller)
    "permission_" + controller.to_s.demodulize.downcase.gsub("controller", "")
  end

end
