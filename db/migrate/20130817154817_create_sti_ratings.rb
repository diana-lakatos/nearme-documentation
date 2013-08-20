class CreateStiRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :author_id, null: false
      t.integer :subject_id
      t.integer :reservation_id

      t.integer :value
      t.text :comment

      t.string :type, null: false

      t.timestamps
    end

    add_column :users, :guest_rating_average, :float
    add_column :users, :guest_rating_count, :integer

    add_column :users, :host_rating_average, :float
    add_column :users, :host_rating_count, :integer
  end
end
