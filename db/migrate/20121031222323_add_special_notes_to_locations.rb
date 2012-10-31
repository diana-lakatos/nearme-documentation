class AddSpecialNotesToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :special_notes, :text
  end
end
