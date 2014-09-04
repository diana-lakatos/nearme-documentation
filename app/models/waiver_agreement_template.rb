class WaiverAgreementTemplate < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :target, :polymorphic => true
  belongs_to :instance

  validates_presence_of :name, :content

end
