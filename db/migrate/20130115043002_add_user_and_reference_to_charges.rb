class AddUserAndReferenceToCharges < ActiveRecord::Migration
  def change
    add_column :charges, :user_id, :integer
    add_column :charges, :reference_type, :string
    rename_column :charges, :reservation_id, :reference_id
  end
end
