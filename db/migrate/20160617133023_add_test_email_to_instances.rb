class AddTestEmailToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :test_email, :string
  end
end
