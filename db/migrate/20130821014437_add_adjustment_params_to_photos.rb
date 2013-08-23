class AddAdjustmentParamsToPhotos < ActiveRecord::Migration
  def change
    change_table :photos do |t|
      t.integer :crop_x, :crop_y, :crop_h, :crop_w, :rotation_angle
    end
  end
end
