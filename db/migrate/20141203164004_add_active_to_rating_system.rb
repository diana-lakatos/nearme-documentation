class AddActiveToRatingSystem < ActiveRecord::Migration
  def change
    add_column :rating_systems, :active, :boolean, default: false
  end
end
