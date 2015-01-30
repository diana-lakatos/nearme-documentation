class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer :rating
      t.string :object
      t.datetime :date
      t.text :comment
      t.references :user, index: true

      t.timestamps
    end
  end
end
