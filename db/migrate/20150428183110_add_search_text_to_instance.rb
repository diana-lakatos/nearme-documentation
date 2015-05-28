class AddSearchTextToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :search_text, :string
  end
end
