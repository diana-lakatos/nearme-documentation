class AddSupportTables < ActiveRecord::Migration
  def change
    create_table(:support_faqs) do |t|
      t.references :instance

      t.text :question, null: false
      t.text :answer, null: false
      t.integer :order, null: false

      t.references :created_by
      t.references :updated_by
      t.references :deleted_by
      t.datetime :deleted_at
      t.timestamps
    end

    create_table(:support_tickets) do |t|
      t.references :instance
      t.references :user
      t.references :assigned_to

      t.string :state, null: false
      t.timestamps
    end

    create_table(:support_ticket_messages) do |t|
      t.references :instance
      t.references :user
      t.references :ticket

      t.string :full_name, null: false
      t.string :email, null: false
      t.string :subject, null: false
      t.text :message, null: false
      t.timestamps
    end

    add_column :instances, :metadata, :text

    add_index :support_faqs, :instance_id
    add_index :support_faqs, :created_by_id
    add_index :support_faqs, :updated_by_id
    add_index :support_faqs, :deleted_by_id
    add_index :support_faqs, :deleted_at

    add_index :support_tickets, :instance_id
    add_index :support_tickets, :user_id
    add_index :support_tickets, :assigned_to_id

    add_index :support_ticket_messages, :instance_id
    add_index :support_ticket_messages, :user_id
    add_index :support_ticket_messages, :ticket_id
  end
end
