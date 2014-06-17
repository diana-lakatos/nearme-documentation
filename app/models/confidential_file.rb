class ConfidentialFile < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :uploader, class_name: 'User'
  belongs_to :owner, polymorphic: true
  attr_accessible :caption, :file, :state

  scope :accepted, lambda { with_state(:accepted) }
  scope :uploaded, lambda { with_state(:uploaded) }
  scope :pending, lambda { with_state(:pending) }
  scope :rejected, lambda { with_state(:rejected) }
  scope :questioned, lambda { with_state(:questionable) }

  mount_uploader :file, PrivateFileUploader
  validates_presence_of :file
  skip_callback :commit, :after, :remove_file!

  state_machine :state, :initial => :uploaded do
    after_transition :accepted => :pending, :do => :notify_owner_of_cancelling_acceptance
    after_transition :pending => :accepted, :do => :notify_owner_of_acceptance

    event :review do
      transition [:uploaded, :accepted, :rejected, :questionable] => :pending
    end

    event :accept do
      transition pending: :accepted
    end

    event :reject do
      transition pending: :rejected
    end

    event :question do
      transition pending: :questionable
    end

  end

  def notify_owner_of_cancelling_acceptance
    owner.confidential_file_acceptance_cancelled! if owner.respond_to?(:confidential_file_acceptance_cancelled!)
  end

  def notify_owner_of_acceptance
    owner.confidential_file_accepted! if owner.respond_to?(:confidential_file_accepted!)
  end
end
