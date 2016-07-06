class CreateTransactableCollaborators < ActiveRecord::Migration
  def change
    create_table :transactable_collaborators do |t|
      t.integer :instance_id
      t.integer :user_id
      t.integer :transactable_id
      t.datetime :approved_by_user_at
      t.datetime :approved_by_owner_at
      t.string :email
      t.datetime :deleted_at
      t.timestamps null: false
    end

    add_index :transactable_collaborators, :instance_id
    add_index :transactable_collaborators, :user_id
    add_index :transactable_collaborators, :transactable_id
  end
end
