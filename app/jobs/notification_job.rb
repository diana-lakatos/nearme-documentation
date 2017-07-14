# frozen_string_literal: true
class NotificationJob < Job
  include Job::HighPriority

  def after_initialize(notification_id:, notification_type:, form_configuration_id:, model_class:, model_id:, params:)
    @notification_id = notification_id
    @notification_type = notification_type
    @form_configuration_id = form_configuration_id
    @model_class = model_class
    @model_id = model_id
    @params = params.to_h
  end

  def perform
    @notification = @notification_type.constantize.find(@notification_id)
    @form = FormConfiguration.find(@form_configuration_id)
                             .build(@model_class.find(@model_id))
                             .tap { |f| f.validate(@params) }
    Notification::SendNotification.call(notification: @notification, form: @form, params: @params)
  end

  def self.priority
    0
  end
end
