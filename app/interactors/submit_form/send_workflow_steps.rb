# frozen_string_literal: true
class SubmitForm
  class SendWorkflowSteps
    def notify(form_configuration:, form:, **)
      return if form_configuration.nil?
      form_configuration.workflow_steps.select('workflow_steps.associated_class, workflow_steps.id').find_each do |step|
        WorkflowStepJob.perform(step.associated_class.constantize, form.model.id, step_id: step.id)
      end
    end
  end
end
