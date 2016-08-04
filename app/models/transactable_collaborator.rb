class TransactableCollaborator < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :user

  counter_culture :user,
    column_name: ->(p) { p.approved? ? 'transactable_collaborators_count' : nil },
    column_names: { ["transactable_collaborators.approved_by_owner_at IS NOT NULL AND transactable_collaborators.approved_by_user_at IS NOT NULL AND transactable_collaborators.deleted_at IS NULL"] => 'transactable_collaborators_count' }

  belongs_to :transactable

  validates :user, presence: { message: I18n.t(:not_exist)}
  validates_uniqueness_of :user, scope: :transactable_id

  validates :transactable, presence: true

  scope :approved, -> { where.not(approved_by_owner_at: nil, approved_by_user_at: nil) }
  scope :for_user, -> (user) { user.present? ? where('user_id = ? OR email = ?', user.id, user.email) : [] }

  before_save :auto_confirm

  def name
    @name ||= user.try(:name)
  end

  def pending?
    !approved?
  end

  def approved?
    approved_by_owner_at.present? && approved_by_user_at.present?
  end

  def approved=(approve=nil)
    self.update_attribute(:approved_by_owner_at, Time.zone.now) if approve.present?
  end

  def approve_by_owner!
    touch(:approved_by_owner_at)

  end

  def approve_by_user!
    touch(:approved_by_user_at)
  end

  def approved_by_user?
    approved_by_user_at.present?
  end

  def approved_by_owner?
    approved_by_owner_at.present?
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

end
