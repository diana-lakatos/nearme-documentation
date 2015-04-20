class Add < ActiveRecord::Migration
  def change
    add_column :saved_searches, :new_results, :integer, default: 0
  end
end
