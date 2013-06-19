class RemoveRatings < ActiveRecord::Migration

  def up
    drop_table :ratings
    remove_column :listings, :rating_average
    remove_column :listings, :rating_count
  end

  def down
    create_table :ratings do |t|
      t.references :content, :polymorphic => true
      t.references :user
      t.float :rating
      t.timestamps
      t.datetime :deleted_at
    end
    add_column :listings, :rating_average, :float, :default => 0.0
    add_column :listings, :rating_count, :integer, :default => 0
  end

end
