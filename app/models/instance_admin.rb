class InstanceAdmin < ActiveRecord::Base

  attr_accessible :instance_id, :user_id, :instance_admin_role_id, :instance_owner

  belongs_to :instance
  belongs_to :user, :foreign_key => :user_id
  belongs_to :instance_admin_role

  before_create :mark_as_instance_owner
  before_save :assign_default_role_if_empty

  validates_presence_of :user_id, :instance_id
  validates_uniqueness_of :user_id, :scope => :instance_id

  delegate :name, :to => :user

  def assign_default_role_if_empty
     assign_default_role unless instance_admin_role_id.present?
  end

  def assign_default_role
    self.instance_admin_role_id = InstanceAdminRole.default_role.try(:id)
  end

  def mark_as_instance_owner
    return unless self.instance_id
    self.instance ||= Instance.find(self.instance_id)
    if instance.instance_admins.empty?
      self.instance_owner = true
      self.instance_admin_role_id = InstanceAdminRole.administrator_role.try(:id)
    end
  end

end
