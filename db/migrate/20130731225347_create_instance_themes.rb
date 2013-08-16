class CreateInstanceThemes < ActiveRecord::Migration
  def change
    create_table :instance_themes do |t|
      t.integer :instance_id
      t.string :name

      t.string :compiled_stylesheet

      t.string :icon_image
      t.string :icon_retina_image
      t.string :logo_image
      t.string :logo_retina_image
      t.string :hero_image
      t.string :color_blue
      t.string :color_red
      t.string :color_orange
      t.string :color_green
      t.string :color_gray
      t.string :color_black
      t.string :color_white

      t.timestamps
    end
  end
end
