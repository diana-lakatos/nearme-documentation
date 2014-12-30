class AddStatusToDataUploads < ActiveRecord::Migration
  def change
    add_column :data_uploads, :state, :string
  end
end
