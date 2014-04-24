class AddInstanceIdToChargesAndRefunds < ActiveRecord::Migration
  def change
    add_column :charges, :instance_id, :integer
    add_column :refunds, :instance_id, :integer
  end
end
