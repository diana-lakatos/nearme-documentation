class RemoveAboutFromTopics < ActiveRecord::Migration
  def change
    remove_column :topics, :about, :text
  end
end
