class CreateOrganizationUsers < ActiveRecord::Migration
  def up
    create_table :organization_users do |t|
      t.integer :organization_id
      t.integer :user_id
    end
  end

  def down
    drop_table :organization_users
  end
end
