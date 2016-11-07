# frozen_string_literal: true
class AddDebuggingModeForAdminsToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :debugging_mode_for_admins, :boolean, default: true
  end
end
