# frozen_string_literal: true
# contains common methods for objects that use Approval Requests
module Approvable
  extend ActiveSupport::Concern

  def approval_request_templates
    @approval_request_templates ||= PlatformContext.current.instance.approval_request_templates.for(self.class.name).older_than(created_at)
  end

  def is_trusted?
    if approval_request_templates.any?
      approval_requests.approved.any?
    else
      ancestors = [try(:company), try(:creator)].compact
      if ancestors.first
        ancestors.first.is_trusted?
      else
        # Not tied to anything, so it's trusted
        true
      end
    end
  end

  def approval_request_acceptance_cancelled!
    listings.find_each(&:approval_request_acceptance_cancelled!)
  end

  def approval_request_approved!
    listings.find_each(&:approval_request_approved!)
  end

  def current_approval_requests
    approval_requests.to_a.reject { |ar| !approval_request_templates.pluck(:id).include?(ar.approval_request_template_id) }
  end
end
