class AddSplitRegistrationToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :split_registration, :boolean, default: false
  end
end
