class RemoveObjectFromReviews < ActiveRecord::Migration
  def up
    Rake::Task['transactable_types:fix_rating_systems'].invoke
    remove_column :reviews, :object
  end

  def down
    add_column :reviews, :object, :string
  end
end
