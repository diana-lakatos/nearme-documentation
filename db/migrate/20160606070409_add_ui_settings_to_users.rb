# frozen_string_literal: true
class AddUiSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ui_settings, :text, default: '{}'
  end
end
