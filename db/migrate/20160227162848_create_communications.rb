class CreateCommunications < ActiveRecord::Migration
  def change
    create_table :communications do |t|
      t.integer :user_id
      t.string :provider
      t.string :provider_key
      t.string :phone_number
      t.string :phone_number_key
      t.string :request_key
      t.boolean :verified, default: false
      t.timestamps null: false
    end
  end
end
