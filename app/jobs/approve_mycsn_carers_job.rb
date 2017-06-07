# frozen_string_literal: true
require 'slack-notifier'
class ApproveMycsnCarersJob < Job
  def perform
    notifier.ping('Automatic approval process started', icon_emoji: ':face_with_head_bandage:')
    user_profiles = InstanceProfileType.seller.first.user_profiles.includes(:user).select { |s| !s.approved && s.onboarded_at.present? && s.properties.onboarding_step_four && s.user.present? && s.user.external_id.present? }
    user_profiles.each do |up|
      up.approved = true
      up.enabled = true
      up.save(validate: false)
      WorkflowStepJob.perform(WorkflowStep::UserWorkflow::ProfileApproved, up.user_id, as: up.user)
    end
    notifier.ping("Done! Users approved:\n#{user_profiles.map { |up| up.user.email }.join("\n")}", icon_emoji: ':face_with_head_bandage:')
  end

  protected

  def notifier
    @notifier ||= Slack::Notifier.new('https://hooks.slack.com/services/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')
  end
end
