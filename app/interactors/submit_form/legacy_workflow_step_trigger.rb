# frozen_string_literal: true
class SubmitForm
  class LegacyWorkflowStepTrigger
    def initialize(klass, id = nil, metadata: {})
      @klass = klass
      @id = id
      @metadata = metadata
    end

    def notify(form:, current_user:, **)
      WorkflowStepJob.perform(@klass, @id || form.model.id, metadata: @metadata, as: current_user)
    end
  end
end
