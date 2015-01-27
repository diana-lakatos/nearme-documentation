class ChangePaymentReferenceRelation < ActiveRecord::Migration
  def change
    rename_column :payments, :reference_type, :payable_type
    rename_column :payments, :reference_id, :payable_id
  end
end
