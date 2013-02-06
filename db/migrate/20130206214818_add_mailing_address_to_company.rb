class AddMailingAddressToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :mailing_address, :text
  end
end
