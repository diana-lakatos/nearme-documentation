class InstanceDrop < BaseDrop

  attr_reader :instance
  delegate :name, :enable_reply_button_on_host_reservations?, :documents_upload_enabled?, :action_rfq?,
    :manual_transfers?, to: :instance

  def initialize(instance)
    @instance = instance
  end

  # url to the MPO administration area
  def instance_admin_url
    routes.instance_admin_path(token_key => @instance.instance_admins.last.user.try(:temporary_token))
  end

end
