# frozen_string_literal: true
class UserSignup
  class EnquirerUserSignup < UserSignup
    def save
      super
      WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::EnquirerAccountCreated, model.id)

      model.default_profile ||= model.create_default_profile(instance_profile_type: PlatformContext.current.instance.default_profile_type)
      model.buyer_profile ||= model.create_buyer_profile(instance_profile_type: PlatformContext.current.instance.buyer_profile_type)

      model.companies.create!(name: user.name, creator: user, metadata: { draft_at: nil, completed_at: Time.zone.now }) if model.buyer_profile.instance_profile_type.create_company_on_sign_up? && model.companies.count.zero?
    end
  end
end
