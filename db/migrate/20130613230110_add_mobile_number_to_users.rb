class AddMobileNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mobile_country_code, :integer
    add_column :users, :mobile_number, :string
  end
end
