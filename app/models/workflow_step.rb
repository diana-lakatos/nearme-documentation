class WorkflowStep < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  validates_presence_of :name
  validates_presence_of :associated_class

  has_many :workflow_alerts, dependent: :destroy
  belongs_to :workflow
  belongs_to :instance
  validates_uniqueness_of :associated_class, scope: [:instance_id, :deleted_at]

  scope :for_associated_class, -> (event) { where(associated_class: event) }

  serialize :custom_options, Hash

end

