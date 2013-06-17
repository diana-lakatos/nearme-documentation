class AddMobileNumberToUsers < ActiveRecord::Migration
  def up
    add_column :users, :country_name, :string
    add_column :users, :mobile_number, :string
  end

  def down
    remove_column :users, :mobile_country_code
    remove_column :users, :mobile_number
  end
end
