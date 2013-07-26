class DropSearchQueriesTable < ActiveRecord::Migration
  def up
    drop_table :search_queries
  end

  def down
    create_table :search_queries do |t|
      t.string :query
      t.text :agent
      t.timestamps
    end
  end
end
