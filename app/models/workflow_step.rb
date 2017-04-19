# frozen_string_literal: true
class WorkflowStep < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  validates :name, presence: true
  validates :associated_class, presence: true

  has_many :workflow_alerts, dependent: :destroy
  has_many :form_configurations_workflows, dependent: :destroy
  has_many :form_configurations, through: :form_configurations_workflows
  belongs_to :workflow
  belongs_to :instance
  validates :associated_class, uniqueness: { scope: [:instance_id, :deleted_at] }

  scope :for_associated_class, ->(event) { where(associated_class: event) }

  serialize :custom_options, Hash
end
