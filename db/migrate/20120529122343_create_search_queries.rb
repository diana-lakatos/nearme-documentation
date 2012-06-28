class CreateSearchQueries < ActiveRecord::Migration
  def self.up
    create_table :search_queries do |t|
      t.string :query
      t.text :agent

      t.timestamps
    end
  end

  def self.down
    drop_table :search_queries
  end
end
