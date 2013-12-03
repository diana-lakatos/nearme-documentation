class InstanceDrop < BaseDrop

  def initialize(instance)
    @instance = instance
  end

  def name
    @instance.name
  end

  def instance_admin_url
    routes.instance_admin_url(host: @instance.domains.last.name, token: @instance.instance_admins.last.user.temporary_token)
  end

end
