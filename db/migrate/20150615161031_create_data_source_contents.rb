class CreateDataSourceContents < ActiveRecord::Migration
  def change
    create_table :data_source_contents do |t|
      t.integer :instance_id
      t.integer :data_source_id
      t.hstore :content
      t.string :external_id
      t.datetime :externally_created_at
      t.timestamps
    end
    add_index :data_source_contents, [:instance_id, :data_source_id]

  end
end
