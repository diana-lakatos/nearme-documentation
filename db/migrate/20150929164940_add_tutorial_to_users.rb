class AddTutorialToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tutorial_displayed, :boolean, default: false
  end
end
