class WaiverAgreement < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :target, polymorphic: true
  belongs_to :waiver_agreement_template
  belongs_to :instance

  before_validation :copy_details, on: :create

  validates_presence_of :content, :name, :target, :waiver_agreement_template

  private

  def copy_details
    self.content = waiver_agreement_template.content
    self.name = waiver_agreement_template.name
  end
end
