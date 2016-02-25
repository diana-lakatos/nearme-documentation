class AddClickToCallToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :click_to_call, :boolean, default: false
  end
end
