class AddFieldsToReviews < ActiveRecord::Migration
  def change
    add_reference :reviews, :reservation, index: true
    add_reference :reviews, :instance, index: true 
  end
end
