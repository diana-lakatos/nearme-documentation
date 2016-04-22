class RemoveUserUniquenessIndexForInappropriateReports < ActiveRecord::Migration
  def self.up
    remove_index :inappropriate_reports, name: 'uniq_inappropriate_instance_user_reports_instance_reportable' 
  end

  def self.down
    add_index :inappropriate_reports, [:instance_id, :user_id, :reportable_id, :reportable_type], unique: true, where: '(deleted_at IS NULL)', name: 'uniq_inappropriate_instance_user_reports_instance_reportable' 
  end
end
