class AddDisplayableToReviewsAndForeignKeys < ActiveRecord::Migration
  def change
    add_column :reviews, :buyer_id, :integer, index: true
    add_column :reviews, :seller_id, :integer, index: true
    add_column :reviews, :displayable, :boolean, default: true
    add_column :reviews, :subject, :string, index: true
  end
end
