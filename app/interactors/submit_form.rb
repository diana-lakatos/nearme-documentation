# frozen_string_literal: true
class SubmitForm
  def initialize(form_configuration:, form:, current_user:, params:)
    @form_configuration = form_configuration
    @form = form
    @params = params
    @current_user = current_user
    @success_observers = [
      SubmitForm::DataIntegrityCheck.new, # order is important :|
      SubmitForm::SendNotifications.new,
      SubmitForm::SendWorkflowSteps.new
    ]
    @failure_observers = []
  end

  def call
    if @form.validate(@params) && @form.save
      notify_success_observers
    else
      notify_failure_observers
    end
  end

  def add_success_observer(observer)
    @success_observers << observer
  end

  def add_failure_observer(observer)
    @failure_observers << observer
  end

  protected

  def notify_success_observers
    @success_observers.each do |o|
      o.notify(params: ::LiquidView.sanitize_params(@params),
               form_configuration: @form_configuration,
               form: @form,
               current_user: @current_user)
    end
  end

  def notify_failure_observers
    @failure_observers.each do |o|
      o.notify(params: ::LiquidView.sanitize_params(@params),
               form_configuration: @form_configuration,
               form: @form,
               current_user: @current_user)
    end
  end
end
