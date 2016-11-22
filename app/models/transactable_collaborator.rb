# frozen_string_literal: true
class TransactableCollaborator < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user
  attr_accessor :actor

  counter_culture :user,
                  column_name: ->(p) { p.approved? ? 'transactable_collaborators_count' : nil },
                  column_names: { ['transactable_collaborators.approved_by_owner_at IS NOT NULL AND transactable_collaborators.approved_by_user_at IS NOT NULL AND transactable_collaborators.deleted_at IS NULL'] => 'transactable_collaborators_count' }

  belongs_to :transactable

  validates :user, presence: { message: I18n.t(:not_exist) }
  validates :user, uniqueness: { scope: :transactable_id }

  validates :transactable, presence: true

  scope :approved, -> { where.not(approved_by_owner_at: nil, approved_by_user_at: nil) }
  scope :for_user, -> (user) { user.present? ? where('transactable_collaborators.user_id = ? OR transactable_collaborators.email = ?', user.id, user.email) : [] }

  before_create :auto_confirm
  after_create :trigger_workflow_alert_on_create!
  after_update :trigger_workflow_alert_on_update!
  before_destroy :trigger_workflow_alert_on_destroy!

  def name
    @name ||= user.try(:name)
  end

  def pending?
    !approved?
  end

  def approved?
    approved_by_owner_at.present? && approved_by_user_at.present?
  end

  def approved=(approve = nil)
    update_attribute(:approved_by_owner_at, Time.zone.now) if approve.present?
  end

  def approve_by_owner!
    touch(:approved_by_owner_at)
  end

  def approve_by_user!
    touch(:approved_by_user_at)
  end

  # @return [Boolean] whether the colllaboration has been approved by the collaborating user
  def approved_by_user?
    approved_by_user_at.present?
  end

  # @return [Boolean] whether the collaboration has been approved by the transactable creator
  def approved_by_owner?
    approved_by_owner_at.present? && rejected_by_owner_at.nil?
  end

  def rejected_by_owner?
    rejected_by_owner_at.present?
  end

  def jsonapi_serializer_class_name
    'TransactableCollaboratorJsonSerializer'
  end

  def to_liquid
    @transactable_collaborator_drop ||= TransactableCollaboratorDrop.new(self)
  end

  def auto_confirm
    self.approved_by_user_at = Time.zone.now if transactable.auto_accept_invitation_as_collaborator?
    true
  end

  def trigger_workflow_alert_on_create!
    if approved_by_owner?
      WorkflowStepJob.perform(WorkflowStep::CollaboratorWorkflow::CollaboratorAddedByTransactableOwner, id)
    elsif approved_by_user?
      WorkflowStepJob.perform(WorkflowStep::CollaboratorWorkflow::CollaboratorPendingApproval, id)
    end
  end

  def trigger_workflow_alert_on_update!
    if approved_by_owner_at_changed? || rejected_by_owner_at_changed?
      if approved_by_owner?
        WorkflowStepJob.perform(WorkflowStep::CollaboratorWorkflow::CollaboratorApproved, id)
      else
        WorkflowStepJob.perform(WorkflowStep::CollaboratorWorkflow::CollaboratorDeclined, transactable_id, user_id)
      end
    end
  end

  def trigger_workflow_alert_on_destroy!
    if actor == transactable.creator
      WorkflowStepJob.perform(WorkflowStep::CollaboratorWorkflow::CollaboratorDeclined, transactable_id, user_id)
    elsif actor == user
      WorkflowStepJob.perform(WorkflowStep::CollaboratorWorkflow::CollaboratorHasQuit, transactable_id, user_id)
    end
  end

  def message_context_object
    self
  end

  def user_message_recipient(current_user)
    current_user == user ? transactable.creator : user
  end
end
