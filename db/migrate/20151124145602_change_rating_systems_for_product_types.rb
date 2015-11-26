class ChangeRatingSystemsForProductTypes < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      i.set_context!
      i.product_types.find_each do |pt|
        pt.rating_systems.where(subject: RatingConstants::GUEST).update_all(subject: RatingConstants::HOST)
      end
    end
  end

  def down
    Instance.find_each do |i|
      i.set_context!
      i.product_types.find_each do |pt|
        pt.rating_systems.where(subject: RatingConstants::HOST).update_all(subject: RatingConstants::GUEST)
      end
    end
  end
end
