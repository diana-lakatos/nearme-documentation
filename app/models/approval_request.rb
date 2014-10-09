class ApprovalRequest < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :uploader, class_name: 'User'
  belongs_to :owner, polymorphic: true

  scope :pending, lambda { with_state(:pending) }
  scope :approved, lambda { with_state(:approved) }
  scope :rejected, lambda { with_state(:rejected) }
  scope :questioned, lambda { with_state(:questionable) }

  before_create :set_defaults

  has_many :approval_request_attachments, inverse_of: :approval_request
  accepts_nested_attributes_for :approval_request_attachments, reject_if: lambda { |params| params[:file].nil? && params[:file_cache].nil? }

  validates_presence_of :message, if: lambda { |ar| ar.required_written_verification }

  def set_defaults
    self.state = 'pending'
  end

  state_machine :state, :initial => :pending do
    after_transition :approved => :pending, :do => :notify_owner_of_cancelling_acceptance
    after_transition :pending => :approved, :do => :notify_owner_of_acceptance

    event :review do
      transition [:approved, :rejected, :questionable] => :pending
    end

    event :accept do
      transition pending: :approved
    end

    event :reject do
      transition pending: :rejected
    end

    event :question do
      transition pending: :questionable
    end

  end

  def notify_owner_of_cancelling_acceptance
    owner.approval_request_acceptance_cancelled! if owner.respond_to?(:approval_request_acceptance_cancelled!)
  end

  def notify_owner_of_acceptance
    owner.approval_request_approved! if owner.respond_to?(:approval_request_approved!)
  end
end

