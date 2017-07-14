# frozen_string_literal: true
class SubmitForm
  class SendNotifications
    def notify(form_configuration:, form:, params:, **)
      return if form_configuration.nil? # for backwards compatibility
      NotificationsJob.perform(form_configuration_id: form_configuration.id,
                               model_class: form.model.class,
                               model_id: form.model.id, params: params)
    end
  end
end
