class ChangeEnabledToBeTrueByDefault < ActiveRecord::Migration
  def change
    change_column :transactables, :enabled, :boolean, default: true
  end
end
