class AddPathToContentHolders < ActiveRecord::Migration
  def change
    add_column :content_holders, :inject_pages, :text, array: true, default: []
    add_column :content_holders, :position, :string
  end
end
