class AddDeletedAtWhereNeeded < ActiveRecord::Migration
  def up
    add_column :instance_admins, :deleted_at, :datetime
    add_column :company_industries, :deleted_at, :datetime
    add_column :user_industries, :deleted_at, :datetime
    add_column :domains, :deleted_at, :datetime
    add_column :themes, :deleted_at, :datetime
    add_column :impressions, :deleted_at, :datetime
    add_column :availability_rules, :deleted_at, :datetime
    add_column :guest_ratings, :deleted_at, :datetime
    add_column :host_ratings, :deleted_at, :datetime
    add_column :charges, :deleted_at, :datetime
    add_column :pages, :deleted_at, :datetime
    add_column :user_industries, :id, :primary_key
    add_column :company_industries, :id, :primary_key
  end

  def down
    remove_column :instance_admins, :deleted_at
    remove_column :company_industries, :deleted_at
    remove_column :user_industries, :deleted_at
    remove_column :domains, :deleted_at
    remove_column :themes, :deleted_at
    remove_column :impressions, :deleted_at
    remove_column :availability_rules, :deleted_at
    remove_column :guest_ratings, :deleted_at
    remove_column :host_ratings, :deleted_at
    remove_column :charges, :deleted_at
    remove_column :pages, :deleted_at
    remove_column :user_industries, :id
    remove_column :company_industries, :id
  end
end
