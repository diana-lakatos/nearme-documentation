class AssignedWaiverAgreementTemplate < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :target, polymorphic: true
  belongs_to :waiver_agreement_template
  belongs_to :instance
end
