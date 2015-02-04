class AddDeletedAtToReviewsModels < ActiveRecord::Migration
  def change
    add_column :rating_systems, :deleted_at, :datetime
    add_index :rating_systems, :deleted_at

    add_column :reviews, :deleted_at, :datetime
    add_index :reviews, :deleted_at

    add_column :rating_questions, :deleted_at, :datetime
    add_index :rating_questions, :deleted_at

    add_column :rating_answers, :deleted_at, :datetime
    add_index :rating_answers, :deleted_at

    add_column :rating_hints, :deleted_at, :datetime
    add_index :rating_hints, :deleted_at
  end
end
