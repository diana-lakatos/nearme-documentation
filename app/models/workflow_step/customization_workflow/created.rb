# frozen_string_literal: true
class WorkflowStep::CustomizationWorkflow::Created < WorkflowStep::CustomizationWorkflow::BaseStep
  def enquirer
    @enquirer ||= User.new(email: @customization.properties[:enquirer_email],
                           name: @customization.properties[:enquirer_name])
  end

  def lister
    @customization.user
  end

  def data
    {
      customization: @customization,
      lister: lister,
      enquirer: enquirer
    }
  end
end
