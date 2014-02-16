class InstanceAdminRole < ActiveRecord::Base
  has_paper_trail
  include Metadata

  PERMISSIONS = %w(Analytics Settings Theme Manage Blog)

  attr_accessible :permission_analytics, :permission_settings, :permission_theme, :permission_transfers, :permission_inventories,
    :permission_partners, :permission_users, :permission_pages, :permission_manage, :name


  has_many :instance_admins
  belongs_to :instance

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :instance_id

  after_destroy :assign_default_role_to_instance_admins
  after_commit :populate_instance_admins_metadata!, :if => lambda { |iar| iar.should_populate_metadata? }

  default_scope :order => "name ASC"
  scope :belongs_to_instance, lambda { |instance_id| where('instance_id = ? OR instance_id is null', instance_id) }

  def self.administrator_role
    self.find_by_name_and_instance_id('Administrator', nil)
  end

  def self.default_role
    self.find_by_name_and_instance_id('Default', nil)
  end

  def populate_instance_admins_metadata!
    instance_admins.reload.each { |ia| ia.user_populate_instance_admins_metadata! }
  end

  def should_populate_metadata? 
    # we are interested only in attributes that either became first_permission or stopped being first_permission
    return true if first_permission_have_access_to.nil?
    PERMISSIONS[0..PERMISSIONS.index(first_permission_have_access_to)].any? do |permission|
      metadata_relevant_attribute_changed?("permission_#{permission.downcase}")
    end
  end

  def assign_default_role_to_instance_admins
    instance_admins.find_each do |instance_admin|
      instance_admin.assign_default_role
      instance_admin.save!
    end
  end

  def first_permission_have_access_to
    PERMISSIONS.find { |p| self.send("permission_#{p.downcase}") }
  end

end
