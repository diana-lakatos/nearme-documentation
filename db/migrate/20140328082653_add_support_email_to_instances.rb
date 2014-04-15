class AddSupportEmailToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :support_email, :string
  end
end
