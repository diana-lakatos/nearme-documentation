class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :name
      t.integer :instance_id
      t.timestamps
    end
    add_index :domains, :instance_id
  end
end
