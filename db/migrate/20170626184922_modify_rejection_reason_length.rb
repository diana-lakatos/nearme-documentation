class ModifyRejectionReasonLength < ActiveRecord::Migration
  def self.up
  	change_column :orders, :rejection_reason, :string, limit: 1500
  end

  def self.down
  	change_column :orders, :rejection_reason, :string, limit: 255
  end
end
