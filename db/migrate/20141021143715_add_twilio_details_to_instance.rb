class AddTwilioDetailsToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :twilio_from_number, :string
    add_column :instances, :test_twilio_from_number, :string
    add_column :instances, :encrypted_test_twilio_consumer_key, :string
    add_column :instances, :encrypted_test_twilio_consumer_secret, :string
    add_column :instances, :encrypted_twilio_consumer_key, :string
    add_column :instances, :encrypted_twilio_consumer_secret, :string
  end
end
