class CreateDataSources < ActiveRecord::Migration
  def change
    create_table :data_sources do |t|
      t.integer :instance_id
      t.integer :data_sourcable_id
      t.string :data_sourcable_type
      t.string :type
      t.text :settings
      t.text :fields, array: true, default: []
      t.datetime :deleted_at
      t.datetime :last_synchronized_at
      t.timestamps
    end
    add_index :data_sources, [:instance_id, :data_sourcable_id, :data_sourcable_type], name: 'index_data_sources_on_data_sourcable'
  end
end
