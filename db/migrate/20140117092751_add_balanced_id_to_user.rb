class AddBalancedIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :balanced_user_id, :string
    add_column :users, :encrypted_balanced_user_id, :string

    add_column :users, :balanced_credit_card_id, :string
    add_column :users, :encrypted_balanced_credit_card_id, :string
  end
end
