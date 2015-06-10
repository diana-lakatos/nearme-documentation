class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :commentable_id
      t.string :commentable_type
      t.text :body
      t.string :title
      t.integer :creator_id, index: true
      t.integer :instance_id
      t.datetime :deleted_at
      t.timestamps null: false
      t.index [:instance_id, :commentable_id, :commentable_type], name: 'index_on_commentable'
    end
  end
end
