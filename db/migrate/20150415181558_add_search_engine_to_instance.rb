class AddSearchEngineToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :search_engine, :string, null: false, default: 'postgresql'
  end
end
