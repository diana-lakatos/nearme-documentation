# frozen_string_literal: true
class UserSignup
  class DefaultUserSignup < UserSignup
    def save
      super
      WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::AccountCreated, model.id, as: model)
      model.default_profile ||= model.user_profiles.where(profile_type: 'default', instance_profile_type: PlatformContext.current.instance.default_profile_type).first_or_create!
    end
  end
end
