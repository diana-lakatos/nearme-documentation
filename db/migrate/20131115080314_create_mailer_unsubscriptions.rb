class CreateMailerUnsubscriptions < ActiveRecord::Migration
  def change
    create_table :mailer_unsubscriptions do |t|
      t.references :user
      t.string :mailer

      t.timestamps
    end
    add_index :mailer_unsubscriptions, :user_id
    add_index :mailer_unsubscriptions, [:user_id, :mailer], :unique => true
  end
end
