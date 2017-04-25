# frozen_string_literal: true
class WorkflowStep::CustomizationWorkflow::Created < WorkflowStep::CustomizationWorkflow::BaseStep
  def enquirer
    customization_properties = @customization.properties
    if customization_properties.key?('enquirer_email') && customization_properties.key?('enquirer_name')
      @enquirer ||= User.new(email: customization_properties[:enquirer_email],
                             name: customization_properties[:enquirer_name])
    end
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
