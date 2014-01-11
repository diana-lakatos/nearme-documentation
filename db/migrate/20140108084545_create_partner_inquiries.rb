class CreatePartnerInquiries < ActiveRecord::Migration
  def change
    create_table :partner_inquiries do |t|
      t.string :name
      t.string :company_name
      t.string :email

      t.timestamps
    end
  end
end
