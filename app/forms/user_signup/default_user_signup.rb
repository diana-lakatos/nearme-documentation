# frozen_string_literal: true
class UserSignup
  class DefaultUserSignup < UserSignup
    def save
      super
      WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::AccountCreated, model.id)
      model.default_profile ||= model.create_default_profile(instance_profile_type: PlatformContext.current.instance.default_profile_type)
    end
  end
end
