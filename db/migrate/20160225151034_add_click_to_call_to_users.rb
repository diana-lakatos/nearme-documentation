class AddClickToCallToUsers < ActiveRecord::Migration
  def change
    add_column :users, :click_to_call, :boolean, default: false
  end
end
