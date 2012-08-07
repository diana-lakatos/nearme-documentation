class CreateInquiries < ActiveRecord::Migration
  def change
    create_table :inquiries do |t|

      t.integer  :listing_id, :inquiring_user_id
      t.text     :message

      t.timestamps
    end
  end
end
