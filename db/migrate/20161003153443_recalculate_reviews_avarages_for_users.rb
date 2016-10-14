class RecalculateReviewsAvaragesForUsers < ActiveRecord::Migration
  def up
    Instance.find_each do |instance|
      instance.set_context!

      User.where(id: Review.unscope(:order).select('user_id').
        where(subject: [RatingConstants::HOST, RatingConstants::TRANSACTABLE]).
        group(:user_id)).find_each do |user|
          user.recalculate_left_as_buyer_average_rating!
          user.recalculate_product_avarage_rating!
      end
    end
  end

  def down; end
end
