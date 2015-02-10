class CreateDimensionsTemplates < ActiveRecord::Migration
  def change
    create_table :dimensions_templates do |t|
      t.string :name
      t.integer :creator_id, index: true
      t.integer :instance_id, index: true
      t.decimal :weight, :precision => 8, :scale => 2
      t.decimal :height, :precision => 8, :scale => 2
      t.decimal :width, :precision => 8, :scale => 2
      t.decimal :depth, :precision => 8, :scale => 2
      t.string :unit_of_measure, :default => 'imperial'
      t.string :weight_unit, :default => 'oz'
      t.string :height_unit, :default => 'in'
      t.string :width_unit, :default => 'in'
      t.string :depth_unit, :default => 'in'

      t.timestamps
    end
  end
end
