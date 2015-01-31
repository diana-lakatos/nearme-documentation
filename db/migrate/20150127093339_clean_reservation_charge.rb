class CleanReservationCharge < ActiveRecord::Migration
  def up
    remove_column :charges, :reference_type
    rename_column :charges, :reference_id, :payment_id

    remove_column :refunds, :reference_type
    rename_column :refunds, :reference_id, :payment_id
  end

  def down
    add_column :charges, :reference_type, :string
    rename_column :charges, :payment_id, :reference_id
    add_column :refunds, :reference_type, :string
    rename_column :refunds, :payment_id, :reference_id

    connection.execute "UPDATE charges SET reference_type = 'Payment'"
    connection.execute "UPDATE refunds SET reference_type = 'Payment'"
  end
end
