class InstanceDrop < BaseDrop

  attr_reader :instance
  delegate :name, to: :instance

  def initialize(instance)
    @instance = instance
  end

  def instance_admin_url
    routes.instance_admin_path(token: @instance.instance_admins.last.user.try(:temporary_token))
  end

end
