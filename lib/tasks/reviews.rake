namespace :reviews do
  desc "Populate new foreign keys and flags"
  task populate_new_columns: :environment do
    Instance.find_each do |instance|
      puts instance.name
      instance.set_context!
      Review.find_each do |r|
        if r.rating_system_id.present?
          puts "\tUpdating review(id=#{r.id})"
          r.buyer_id ||= r.reviewable.owner_id
          r.seller_id ||= r.reviewable.creator_id
          r.subject ||= r.rating_system.subject
          if [RatingConstants::HOST, RatingConstants::GUEST].include?(r.subject)
            review = Review.find_by(reviewable_id: r.reviewable_id, reviewable_type: r.reviewable_type, subject: [RatingConstants::HOST, RatingConstants::GUEST])
            review.try(:update_column, :displayable, true)
            if review.present?
              puts "\t\thas corresponding review: #{review.id}"
            end
            if review.nil? && r.transactable_type.show_reviews_if_both_completed
              puts "\t\tmarking as not displayable!"
              r.displayable = false
            end
          end
          r.save!
        else
          puts "\tSkipping review(id=#{r.id}) - no rating system"
        end
      end
      User.find_each do |u|
        u.recalculate_left_as_buyer_average_rating!
        u.recalculate_left_as_seller_average_rating!
      end
    end
  end
end

