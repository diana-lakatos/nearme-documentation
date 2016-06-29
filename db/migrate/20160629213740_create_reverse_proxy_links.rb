class CreateReverseProxyLinks < ActiveRecord::Migration
  def change
    create_table :reverse_proxy_links do |t|
      t.integer :instance_id
      t.string :use_on_path
      t.string :name
      t.string :destination_path
      t.timestamps
    end
  end
end
