class InstanceAdmin::Authorizer
  
  def initialize(user, platform_context)
    @user = user
    @platform_context = platform_context
  end

  def instance_admin?
    instance_admin.present?
  end

  def authorized?(controller)
    if controller.to_s == "InstanceAdmin::BaseController"
      controller = "InstanceAdmin::AnalyticsController"
    end
    instance_admin_role.send(convert_controller_class_to_db_column(controller))
  end

  private

  def instance_admin
    @instance_admin ||= @platform_context.instance.instance_admins.where('instance_admins.user_id = ?', @user.id).first
  end

  def instance_admin_role
    @instance_admin_role ||= instance_admin.instance_admin_role
  end

  def convert_controller_class_to_db_column(controller)
    "permission_" + controller.to_s.demodulize.downcase.gsub("controller", "")
  end
end
