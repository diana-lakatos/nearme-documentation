class ChangeAssociationToPolymorohicForReviews < ActiveRecord::Migration
  def change
    rename_column :reviews, :reservation_id, :reviewable_id
    add_column :reviews, :reviewable_type, :string
    add_index :reviews, :reviewable_type

    Review.update_all( "reviewable_type = 'Reservation'" )
  end
end
