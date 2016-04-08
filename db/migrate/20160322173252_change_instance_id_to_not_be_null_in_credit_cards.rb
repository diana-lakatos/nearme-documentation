class ChangeInstanceIdToNotBeNullInCreditCards < ActiveRecord::Migration
  def change
    change_column :credit_cards, :instance_id, :integer, null: false
  end
end
