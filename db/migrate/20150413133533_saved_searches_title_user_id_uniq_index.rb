class SavedSearchesTitleUserIdUniqIndex < ActiveRecord::Migration
  def change
    add_index :saved_searches, %i(title user_id), unique: true
  end
end
