class CreateReverseProxies < ActiveRecord::Migration
  def change
    create_table :reverse_proxies do |t|
      t.integer :instance_id
      t.integer :domain_id
      t.string :path
      t.string :destination_domain
      t.string :environment
      t.timestamps
    end
    add_index :reverse_proxies, [:instance_id, :domain_id, :path], unique: true
  end
end
