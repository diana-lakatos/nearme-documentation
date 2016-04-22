class AddSchedulableAssociationToScheduleExceptionRules < ActiveRecord::Migration
  def change
    add_column :schedule_exception_rules, :availability_template_id, :integer
    add_index :schedule_exception_rules, :availability_template_id
  end
end
