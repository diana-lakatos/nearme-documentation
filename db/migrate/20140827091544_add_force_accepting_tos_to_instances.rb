class AddForceAcceptingTosToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :force_accepting_tos, :boolean
  end
end
