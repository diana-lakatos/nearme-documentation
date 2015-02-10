# This migration comes from spree (originally 20140106065820)
class RemoveValueTypeFromSpreePreferences < ActiveRecord::Migration
  def change
    remove_column :spree_preferences, :value_type, :string
  end
end
