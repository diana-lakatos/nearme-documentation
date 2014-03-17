class AddInstanceIdToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :instance_id, :integer
  end
end
