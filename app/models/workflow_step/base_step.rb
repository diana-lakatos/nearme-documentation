# frozen_string_literal: true
class WorkflowStep::BaseStep
  attr_reader :lister, :enquirer, :transactable

  def self.belongs_to_transactable_type?
    false
  end

  def invoke!
    alerts.enabled.each do |alert|
      WorkflowAlert::InvokerFactory.get_invoker(alert).invoke!(self) if invokable_alert?(alert)
    end
  end

  def should_be_processed?
    true
  end

  def mail_attachments(_alert)
    []
  end

  # these methods has been implemented for SMS - we might want to truncate one variable, but we don't know
  # the size of the rest of the message ahead of time. think of string like "!{{ a }} !{{ b }} !{{ c }}".
  # If we want the string to be no longer than 160 characters, but we know that a and c together for sure won't
  # exceed it, but b might, and we want to be sure that both a and c are included in the message, we need to
  # have a way to check the size of evaluated !{{ a }} and !{{ c }}, then we can just truncate b to 160 - size of a+c.
  # These methods allows to do just that. They are used for example for UserMessage::Created
  def callback_to_prepare_data_for_check
  end

  def callback_to_adjust_data_after_check(_rendered_view)
  end

  def transactable_type_id
    nil
  end

  protected

  def alerts
    workflow_step.try(:workflow_alerts) || WorkflowAlert.none
  end

  def workflow
    Workflow.for_workflow_type(workflow_type).first
  end

  def workflow_step
    workflow.try(:workflow_steps).try(:for_associated_class, self.class.to_s).try(:includes, :workflow_alerts).try(:first)
  end

  def workflow_type
    raise NotImplementedError, "#{self.class.name} must implemented workflow_type method"
  end

  def data
    {}
  end

  def invokable_alert?(alert)
    # this config will be set to true in production and test environment, false in application.rb
    return true if Rails.application.config.force_sending_all_workflow_alerts
    return true unless %w(sms api_call).include?(alert.alert_type)
    PlatformContext.current.instance.enable_sms_and_api_workflow_alerts_on_staging?
  end
end
