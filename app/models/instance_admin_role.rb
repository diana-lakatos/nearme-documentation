class InstanceAdminRole < ActiveRecord::Base

  attr_accessible :permission_analytics, :permission_settings, :permission_theme, :permission_transfers, :permission_inventory,
    :permission_partners, :permission_users, :name

  has_many :instance_admins
  belongs_to :instance

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :instance_id

  after_destroy :assign_default_role_to_instance_admins
  default_scope :order => "name ASC"
  scope :belongs_to_instance, lambda { |instance_id| where('instance_id = ? OR instance_id is null', instance_id) }

  def self.administrator_role
    self.find_by_name_and_instance_id('Administrator', nil)
  end

  def self.default_role
    self.find_by_name_and_instance_id('Default', nil)
  end

  def assign_default_role_to_instance_admins
    instance_admins.find_each do |instance_admin|
      instance_admin.assign_default_role
      instance_admin.save!
    end
  end

end
