# frozen_string_literal: true
class AuthorizationPolicyAssociation < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :authorization_policy
  belongs_to :authorizable, polymorphic: true
end
