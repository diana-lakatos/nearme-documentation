class CreateIndustries < ActiveRecord::Migration
  def self.up
    create_table :industries do |t|
      t.string :name
      t.timestamps
    end

    create_table :companies_industries, :id => false do |t|
      t.references :industry
      t.references :company
    end

    create_table :industries_users, :id => false do |t|
      t.references :industry
      t.references :user
    end
  end

  def self.down
    drop_table :companies_industries
    drop_table :industries_users
    drop_table :industries
  end
end
