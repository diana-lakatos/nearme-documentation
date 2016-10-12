class InstanceAdmin < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  has_metadata without_db_column: true
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :user, -> { with_deleted }, foreign_key: 'user_id'
  belongs_to :instance_admin_role

  before_create :mark_as_instance_owner_if_none
  before_save :assign_default_role_if_empty

  validates_presence_of :user_id
  validates_uniqueness_of :user_id, scope: :instance_id, conditions: -> { where(deleted_at: nil) }

  delegate :name, to: :user, allow_nil: true
  delegate :first_permission_have_access_to, to: :instance_admin_role, allow_nil: true

  scope :for_user, lambda { |user|
    return none if user.nil?
    where('instance_admins.user_id = ?', user.id)
  }

  def assign_default_role_if_empty
    assign_default_role unless instance_admin_role_id.present?
  end

  def assign_default_role
    self.instance_admin_role_id = InstanceAdminRole.default_role.try(:id)
  end

  def mark_as_instance_owner
    update(instance_owner: true, instance_admin_role_id: InstanceAdminRole.administrator_role.try(:id))
    instance.instance_admins.where(instance_owner: true).where.not(id: id).update_all(instance_owner: false)
  end

  private

  def mark_as_instance_owner_if_none
    return unless instance_id
    self.instance ||= Instance.find(instance_id)
    if instance.instance_admins.empty?
      self.instance_owner = true
      self.instance_admin_role_id = InstanceAdminRole.administrator_role.try(:id)
    end
  end
end
