# frozen_string_literal: true
class UserSignup
  class EnquirerUserSignup < UserSignup
    def save
      super
      model.default_profile ||= model.user_profiles.where(profile_type: 'default', instance_profile_type: PlatformContext.current.instance.default_profile_type).first_or_create!
      model.buyer_profile ||= model.user_profiles.where(profile_type: 'buyer', instance_profile_type: PlatformContext.current.instance.buyer_profile_type).first_or_create!
      model.companies.create!(name: model.name, creator: model, metadata: { draft_at: nil, completed_at: Time.zone.now }) if model.buyer_profile.instance_profile_type.create_company_on_sign_up? && model.companies.count.zero?
      WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::EnquirerAccountCreated, model.id)
    end
  end
end
