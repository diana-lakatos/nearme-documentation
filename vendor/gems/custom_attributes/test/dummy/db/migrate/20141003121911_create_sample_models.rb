class CreateSampleModels < ActiveRecord::Migration
  def self.up
    execute "CREATE EXTENSION IF NOT EXISTS hstore"
    create_table :sample_models do |t|
      t.integer :sample_model_type_id
      t.hstore :properties
      t.timestamps
    end
  end

  def self.down
    execute "DROP EXTENSION IF EXISTS hstore"
    drop_table :sample_models
  end
end
