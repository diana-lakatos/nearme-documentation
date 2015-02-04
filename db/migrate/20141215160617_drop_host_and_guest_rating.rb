class DropHostAndGuestRating < ActiveRecord::Migration
  def up
    drop_table :host_ratings
    drop_table :guest_ratings

    remove_column :users, :guest_rating_average, :float
    remove_column :users, :guest_rating_count, :integer

    remove_column :users, :host_rating_average, :float
    remove_column :users, :host_rating_count, :integer

    remove_column :reservations, :request_guest_rating_email_sent_at, :datetime
    remove_column :reservations, :request_host_rating_email_sent_at, :datetime
  end

  def down 
    create_table :host_ratings do |t|
      t.integer :author_id, null: false
      t.integer :subject_id
      t.integer :reservation_id

      t.integer :value
      t.text :comment

      t.timestamps
    end

    create_table :guest_ratings do |t|
      t.integer :author_id, null: false
      t.integer :subject_id
      t.integer :reservation_id

      t.integer :value
      t.text :comment

      t.timestamps
    end

    add_column :users, :guest_rating_average, :float
    add_column :users, :guest_rating_count, :integer

    add_column :users, :host_rating_average, :float
    add_column :users, :host_rating_count, :integer

    add_column :reservations, :request_guest_rating_email_sent_at, :datetime
    add_column :reservations, :request_host_rating_email_sent_at, :datetime
  end
end
