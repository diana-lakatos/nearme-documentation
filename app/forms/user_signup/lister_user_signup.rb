# frozen_string_literal: true
class UserSignup
  class ListerUserSignup < UserSignup
    def save
      super
      WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::ListerAccountCreated, model.id)
      model.companies.first&.update_metadata(draft_at: nil, completed_at: Time.zone.now)
      model.default_profile ||= model.user_profiles.where(profile_type: 'default', instance_profile_type: PlatformContext.current.instance.default_profile_type).first_or_create!
      model.seller_profile ||= model.user_profiles.where(profile_type: 'seller', instance_profile_type: PlatformContext.current.instance.seller_profile_type).first_or_create!
    end
  end
end
