class ChangeDefaultPriorityForDelayedJob < ActiveRecord::Migration
  def change
      change_column :delayed_jobs, :priority, :integer, default: 20
  end
end
