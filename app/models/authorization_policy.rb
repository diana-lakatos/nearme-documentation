# frozen_string_literal: true
class AuthorizationPolicy < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  validates :name, presence: true, uniqueness: { scope: [:instance_id] }
  validates :content, presence: true, liquid: true

  has_many :authorization_policy_associations, dependent: :destroy
  has_many :authorizables, through: :authorization_policy_associations
end
