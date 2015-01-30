class AddInstanceIdToRatingSystem < ActiveRecord::Migration
  def change
    add_reference :rating_systems, :instance, index: true
  end
end
