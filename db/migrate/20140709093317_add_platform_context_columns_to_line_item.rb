class AddPlatformContextColumnsToLineItem < ActiveRecord::Migration
  def change
    add_column :spree_line_items, :instance_id, :integer
    add_index :spree_line_items, :instance_id
    add_column :spree_line_items, :company_id, :integer
    add_index :spree_line_items, :company_id
    add_column :spree_line_items, :partner_id, :integer
    add_index :spree_line_items, :partner_id
    add_column :spree_line_items, :user_id, :integer
    add_index :spree_line_items, :user_id
  end
end
