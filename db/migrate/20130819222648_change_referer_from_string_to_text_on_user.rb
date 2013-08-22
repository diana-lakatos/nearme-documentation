class ChangeRefererFromStringToTextOnUser < ActiveRecord::Migration
  def up
    change_column :users, :referer, :text
  end

  def down
    change_column :users, :referer, :string
  end
end
