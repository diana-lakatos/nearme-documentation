class AddRequireOrganizationMembershipToLocation < ActiveRecord::Migration
  def up
    add_column :locations, :require_organization_membership, :boolean, :default => false 
  end

  def down
    remove_column :locations, :require_organization_membership
  end
end
