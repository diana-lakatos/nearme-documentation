class CreateInstanceTypes < ActiveRecord::Migration
  def change
    create_table :instance_types do |t|
      t.string :name
      t.timestamps
    end
    add_column :instances, :instance_type_id, :integer
    add_index :instances, :instance_type_id

    create_table :instance_views do |t|
      t.references :instance_type
      t.references :instance
      t.text   :body
      t.string :path
      t.string :locale
      t.string :format
      t.string :handler
      t.boolean :partial, default: false
      t.timestamps
    end
    add_index :instance_views, [:instance_type_id, :instance_id, :path, :locale, :format, :handler], :name => 'instance_path_with_format_and_handler'
  end

end
