# frozen_string_literal: true
class UserSignup
  class ListerUserSignup < UserSignup
    def save
      super
      WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::ListerAccountCreated, model.id)
      model.companies.first&.update_metadata(draft_at: nil, completed_at: Time.zone.now)
      model.default_profile ||= model.create_default_profile(instance_profile_type: PlatformContext.current.instance.default_profile_type)
      model.seller_profile ||= model.create_seller_profile(instance_profile_type: PlatformContext.current.instance.seller_profile_type)
    end
  end
end
