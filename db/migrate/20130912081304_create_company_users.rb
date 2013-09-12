class CreateCompanyUsers < ActiveRecord::Migration
  def change
    create_table :company_users, :id => false do |t|
      t.belongs_to :company
      t.belongs_to :user

      t.timestamps
    end
    add_index :company_users, :company_id
    add_index :company_users, :user_id

    # Add companies creators as company users
    Company.all.each do |company|
      company.users << company.creator if company.creator.present? and !company.users.include?(company.creator)
    end
  end 
end
