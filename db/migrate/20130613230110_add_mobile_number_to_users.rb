class AddMobileNumberToUsers < ActiveRecord::Migration
  def up
    add_column :users, :country_name, :string
    add_column :users, :mobile_number, :string
  end

  def down
    remove_column :users, :country_name
    remove_column :users, :mobile_number
  end
end
