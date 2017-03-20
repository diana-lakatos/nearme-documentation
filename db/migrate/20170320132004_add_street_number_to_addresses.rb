class AddStreetNumberToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :street_number, :string
  end
end
