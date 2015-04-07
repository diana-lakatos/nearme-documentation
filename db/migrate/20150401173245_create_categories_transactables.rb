class CreateCategoriesTransactables < ActiveRecord::Migration
  def change
    create_table :categories_transactables do |t|
      t.belongs_to :category, index: true
      t.belongs_to :transactable, index: true
      t.timestamps
    end
  end
end
