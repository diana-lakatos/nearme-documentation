class AddProgressToDataUploads < ActiveRecord::Migration
  def change
    add_column :data_uploads, :progress_percentage, :integer
  end
end
