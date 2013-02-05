class AddPayPalEmailToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :paypal_email, :string
  end
end
