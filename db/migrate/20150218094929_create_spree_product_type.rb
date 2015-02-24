class CreateSpreeProductType < ActiveRecord::Migration
  def change
    create_table :spree_product_types do |t|
    	t.string :name
    	t.integer  :instance_id
	    t.datetime :deleted_at
    end
  end
end
