class CreateMerchantAccountOwners < ActiveRecord::Migration
  def change
    create_table :merchant_account_owners do |t|
      t.references :instance, index: true
      t.references :merchant_account, index: true

      t.text :data
      t.string :document
      t.string :type


      t.timestamps
    end
  end
end
