class AddDescriptionToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :description, :text
  end
end
