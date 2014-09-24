class Authorizer

  def initialize(user)
    @user = user
  end

  def instance_admin?
    instance_admin.present?
  end

  private

  def instance_admin
    @instance_admin ||= @user.instance_admins.first
  end

  def instance_owner?
    instance_admin.try(:instance_owner?)
  end

  def instance_admin_role
    @instance_admin_role ||= instance_admin.try(:instance_admin_role)
  end

end
