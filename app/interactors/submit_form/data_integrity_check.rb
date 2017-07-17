# frozen_string_literal: true
class SubmitForm
  class DataIntegrityCheck
    def notify(form:, form_configuration:, **)
      return if form_configuration.nil? # backwards compatibility :|
      raise "Form #{form_configuration.name} was submitted successfuly but model has not been persisted.\
Errors: #{form.model.errors.full_messages.join(', ')}" if form.model.changed?
    end
  end
end

