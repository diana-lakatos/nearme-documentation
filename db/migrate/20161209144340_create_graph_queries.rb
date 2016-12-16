class CreateGraphQueries < ActiveRecord::Migration
  def change
    create_table :graph_queries do |t|
      t.references :instance, index: true
      t.string :name
      t.text :query_string

      t.timestamps null: false
    end
  end
end
