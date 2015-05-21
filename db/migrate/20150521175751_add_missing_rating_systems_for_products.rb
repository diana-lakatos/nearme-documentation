class AddMissingRatingSystemsForProducts < ActiveRecord::Migration

  def up
    Spree::ProductType.unscoped.where(deleted_at: nil).find_each do |pt|
      pt.create_rating_systems if pt.rating_systems.empty?
    end
  end

end
