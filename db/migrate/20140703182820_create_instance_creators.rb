class CreateInstanceCreators < ActiveRecord::Migration
  def change
    create_table :instance_creators do |t|
      t.string :email, index: true
      t.boolean :created_instance
      t.integer :instance_id
      t.timestamps
    end
    add_index :instance_creators, :email
  end
end
