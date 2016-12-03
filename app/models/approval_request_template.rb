class ApprovalRequestTemplate < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  OWNER_TYPES = %w(User Company Transactable Offer)

  belongs_to :instance
  has_many :approval_request_attachment_templates, inverse_of: :approval_request_template

  scope :for, -> (owner_type) { where owner_type: owner_type }
  scope :older_than, -> (date) { where('created_at < ?', date) if date }

  validates_inclusion_of :owner_type, in: ApprovalRequestTemplate::OWNER_TYPES

  accepts_nested_attributes_for :approval_request_attachment_templates, allow_destroy: true,
                                reject_if: ->(params) { params.blank? || params[:label].blank? }

end
