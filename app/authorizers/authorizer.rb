class Authorizer

  def initialize(user, platform_context)
    @user = user
    @platform_context = platform_context
  end

  def instance_admin?
    instance_admin.present?
  end

  private

  def instance_admin
    @instance_admin ||= @platform_context.instance.instance_admins.where('instance_admins.user_id = ?', @user.id).first
  end

  def instance_owner?
    instance_admin.present? && instance_admin.instance_owner
  end

  def instance_admin_role
    @instance_admin_role ||= instance_admin.instance_admin_role
  end

end
