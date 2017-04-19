# frozen_string_literal: true
class WorkflowStep::CustomizationWorkflow::BaseStep < WorkflowStep::BaseStep
  def initialize(customization_id)
    @customization = Customization.find_by(id: customization_id)
  end

  def lister
    raise NotImplementedError, "#{self.class.name} has to define lister method"
  end

  def workflow_type
    'customization_workflow'
  end

  def should_be_processed?
    true
  end
end
