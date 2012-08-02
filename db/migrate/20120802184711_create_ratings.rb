class CreateRatings < ActiveRecord::Migration
  def up
    create_table :ratings do |t|
      t.references :content, :polymorphic => true
      t.references :user
      t.float :rating

      t.timestamps
      t.datetime :deleted_at
    end
  end

  def down
    drop_table :ratings
  end
end
