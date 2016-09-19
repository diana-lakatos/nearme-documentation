class AddSearchEngineForInstanceProfileType < ActiveRecord::Migration
  def change
    add_column :instance_profile_types, :search_engine, :string, limit: 255, default: "postgresql", null: false
  end
end
