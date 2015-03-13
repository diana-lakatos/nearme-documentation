class RemoveQuantityFromCustomAttributes < ActiveRecord::Migration
  class CustomAttribute < ActiveRecord::Base
  end

  def up
    CustomAttribute.where(name: 'quantity').delete_all
  end

  def down

  end
end
