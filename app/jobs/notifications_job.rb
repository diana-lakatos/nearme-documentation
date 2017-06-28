# frozen_string_literal: true
class NotificationsJob < Job
  include Job::HighPriority

  def after_initialize(form_configuration_id:, model_class:, model_id:, params:)
    @form_configuration_id = form_configuration_id
    @model_class = model_class
    @model_id = model_id
    @params = params.to_h
  end

  def perform
    form_configuration = FormConfiguration.find(@form_configuration_id)
    form_configuration.form_configuration_notifications.includes(:notification).each do |form_configuration_notification|
      notification = form_configuration_notification.notification
      next unless notification.enabled?
      NotificationJob.perform_later(notification.delay.minutes.from_now,
                                    notification_id: form_configuration_notification.notification_id,
                                    notification_type: form_configuration_notification.notification_type,
                                    form_configuration_id: @form_configuration_id,
                                    model_class: @model_class, model_id: @model_id, params: @params)
    end
  end

  def self.priority
    0
  end
end
