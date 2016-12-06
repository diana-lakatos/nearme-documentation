# frozen_string_literal: true
class InstanceDrop < BaseDrop
  # @return [InstanceDrop]
  attr_reader :instance

  # @!method name
  #   @return [String] name of the instance
  # @!method enable_reply_button_on_host_reservations?
  #   @return [Boolean] whether to enable reply button on reservations for hosts
  # @!method documents_upload_enabled?
  #   @return [Boolean] whether documents upload is enabled
  # @!method action_rfq?
  #   @return [Boolean] whether any of the action types have request for quotation enabled
  # @!method manual_transfers?
  #   @return [Boolean] whether the payment transfers frequency is set to manual
  delegate :name, :enable_reply_button_on_host_reservations?, :documents_upload_enabled?, :action_rfq?,
           :manual_transfers?, to: :instance

  def initialize(instance)
    @instance = instance
  end

  # @return [String] url to the MPO administration area
  # @todo -- deprecate - url filter
  def instance_admin_url
    routes.instance_admin_path(token_key => @instance.instance_admins.last.user.try(:temporary_token))
  end
end
