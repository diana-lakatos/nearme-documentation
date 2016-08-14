class Workflow < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  validates_presence_of :name
  serialize :events_metadata, Hash

  has_many :workflow_steps, dependent: :destroy
  belongs_to :instance

  scope :for_workflow_type, -> (workflow_type) { where(workflow_type: workflow_type) }

end

