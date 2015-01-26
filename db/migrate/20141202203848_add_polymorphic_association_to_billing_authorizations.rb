class AddPolymorphicAssociationToBillingAuthorizations < ActiveRecord::Migration
  def up
    add_column :billing_authorizations, :reference_type, :string
    add_column :billing_authorizations, :reference_id, :integer
    add_index :billing_authorizations, [:reference_id, :reference_type]

    connection.execute <<-SQL
      UPDATE billing_authorizations
      SET
        reference_id = reservation_id,
        reference_type = 'Reservation'
      WHERE
        reservation_id IS NOT NULL
    SQL
  end

  def down
    remove_column :billing_authorizations, :reference_type
    remove_column :billing_authorizations, :reference_id
  end
end
