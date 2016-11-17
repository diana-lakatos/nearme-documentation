class WaiverAgreementTemplate < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :target, polymorphic: true
  belongs_to :instance

  has_many :assigned_waiver_agreement_templates, dependent: :destroy

  validates :name, :content, presence: true

  def to_liquid
    @waiver_agreement_template_drop ||= WaiverAgreementTemplateDrop.new(self)
  end
end
