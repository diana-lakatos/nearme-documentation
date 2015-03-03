class CalculateAverageRatingForTransactable < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      PlatformContext.current = PlatformContext.new(i)

      reservation_ids = Review.where(reviewable_type: 'Reservation', object: 'product').pluck(:reviewable_id)
      transactable_ids = Reservation.where(id: reservation_ids).pluck(:transactable_id)

      Transactable.where(id: transactable_ids).find_each do |transactable|
        average_rating = transactable.reviews.average(:rating)
        transactable.update_column(:average_rating, average_rating)
      end
    end
  end

  def down
  end
end
