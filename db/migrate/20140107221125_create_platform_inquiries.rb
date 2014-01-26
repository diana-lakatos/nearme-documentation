class CreatePlatformInquiries < ActiveRecord::Migration
  def change
    create_table :platform_inquiries do |t|
      t.string :name
      t.string :surname
      t.string :email
      t.string :industry
      t.text :message
      
      t.timestamps
    end
  end
end
