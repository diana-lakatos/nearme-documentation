class PopulateTypeInTransactableType < ActiveRecord::Migration

  class Spree::OldProductType < ActiveRecord::Base
  end

  def up
    #TransactableType.where(buyable: true).with_deleted.delete_all
  end

  def down

  end
end
