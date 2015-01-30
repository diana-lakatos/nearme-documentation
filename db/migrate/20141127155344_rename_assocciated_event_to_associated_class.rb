class RenameAssocciatedEventToAssociatedClass < ActiveRecord::Migration
  def change
    rename_column :workflow_steps, :associated_event, :associated_class
  end
end
