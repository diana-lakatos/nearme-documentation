class CreatePhoneCalls < ActiveRecord::Migration
  def change
    create_table :phone_calls do |t|
      t.integer :caller_id
      t.string  :from
      t.integer :receiver_id
      t.string  :to
      t.string  :phone_call_key
      t.timestamps null: false
    end
  end
end
