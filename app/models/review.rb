class Review < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  acts_as_paranoid

  self.per_page = 10

  LAST_30_DAYS = '30_days'
  LAST_6_MONTHS = '6_months'
  DATE_VALUES = ['today', 'yesterday', 'week_ago', 'month_ago', '3_months_ago', '6_months_ago']

  belongs_to :user
  belongs_to :reviewable, polymorphic: true
  belongs_to :instance
  belongs_to :transactable_type
  belongs_to :rating_system

  has_many :rating_answers, -> { order(:id) }, dependent: :destroy

  validates_presence_of :rating, :user, :reviewable, :transactable_type
  validates :rating, inclusion: { in: RatingConstants::VALID_VALUES , message: :rating_is_required }
  validate  :creator_does_not_review_own_objects

  default_scope { order('reviews.created_at DESC') }

  scope :with_rating, ->(rating_value) { where(rating: rating_value) }
  scope :with_date, ->(date) { where(created_at: date) }
  scope :with_transactable_type, ->(transactable_type_id) { where(transactable_type_id: transactable_type_id) }
  scope :by_reservations, ->(id) { where(reviewable_id: id, reviewable_type: 'Reservation').includes(rating_answers: [:rating_question]) }
  scope :by_line_items, ->(id) { where(reviewable_id: id, reviewable_type: 'Spree::LineItem').includes(rating_answers: [:rating_question]) }
  scope :for_buyer, ->{ with_object(RatingConstants::BUYER) }
  scope :for_seller, ->{ with_object(RatingConstants::SELLER) }
  scope :for_seller_and_product, -> { with_object([RatingConstants::SELLER, RatingConstants::PRODUCT]) }
  scope :by_search_query, -> (query) { joins(:user).where("users.name ILIKE ?", query) }

  def recalculate_reviewable_average_rating
    if self.reviewable.is_a?(Spree::LineItem)
      recalculate_by_type(-> { self.reviewable.product.user.recalculate_seller_average_rating! },
                          -> { self.reviewable.order.user.recalculate_buyer_average_rating! },
                          -> { self.reviewable.product.recalculate_average_rating! })
    else
      recalculate_by_type(-> { self.reviewable.creator.recalculate_seller_average_rating! },
                          -> { self.reviewable.owner.recalculate_buyer_average_rating! },
                          -> { self.reviewable.listing.recalculate_average_rating! })
    end
  end

  def self.both_sides_reviewed_for(object, user_id)
    subject = RatingConstants::RATING_MAPPING[object]

    raise "You can't ask for another side review from a transactable." if subject == RatingConstants::TRANSACTABLE
    
    opposite_subject = if subject == RatingConstants::HOST
      RatingConstants::GUEST
    else
      RatingConstants::HOST
    end

    select_string = <<-SQL
      DISTINCT reviews.*
    SQL

    join_string = <<-SQL
      -- Join the user's rating_system
      INNER JOIN rating_systems AS user_rating_systems ON
        reviews.rating_system_id = user_rating_systems.id
    SQL

    where_string = <<-SQL
      user_rating_systems.subject = '$opposite_subject' AND
      reviews.user_id = '$user_id' AND
      
      EXISTS (
        SELECT *
        FROM reviews AS other_side_reviews
        INNER JOIN rating_systems AS other_side_rating_systems ON
          other_side_reviews.rating_system_id = other_side_rating_systems.id
        WHERE
          other_side_rating_systems.subject = '$subject' AND
          other_side_reviews.reviewable_id = reviews.reviewable_id AND
          other_side_reviews.reviewable_type = reviews.reviewable_type
      )

      OR 

      user_rating_systems.subject = 'transactable' AND
      reviews.user_id = '$user_id'
    SQL

    where_string.gsub!("$subject", subject)
    where_string.gsub!("$opposite_subject", opposite_subject)
    where_string.gsub!("$user_id", user_id.to_s)

    select(select_string).joins(join_string).where(where_string)
  end

  def self.reviews_from(object)
    select_string = <<-SQL
      DISTINCT reviews.*
    SQL

    join_string = <<-SQL
      INNER JOIN reviews AS rev ON 
      rev.reviewable_type = reviews.reviewable_type AND 
      rev.reviewable_id = reviews.reviewable_id
      
      INNER JOIN rating_systems as rs ON
      reviews.rating_system_id = rs.id
    SQL

    where_string = <<-SQL
      rs.subject = 'transactable' OR
      rs.subject = '$subject' OR

      NOT (
        SELECT tt.show_reviews_if_both_completed 
        FROM transactable_types AS tt 
        WHERE tt.id = reviews.transactable_type_id
      )
    SQL

    where_string.gsub!("$subject", RatingConstants::RATING_MAPPING[object])
    select(select_string).joins(join_string).where(where_string)
  end


  def self.with_object(object)
    subject = if object.is_a?(Array)
      object.map { |object| RatingConstants::RATING_MAPPING[object] }
    else
      RatingConstants::RATING_MAPPING[object]
    end

    includes(:rating_system).
    where(rating_systems: { subject: subject })
  end

  protected

  def creator_does_not_review_own_objects
    if user_id.present? && (user_id == reviewable.try(:creator_id) && user_id == reviewable.try(:owner_id))
      errors.add(:base, I18n.t('errors.messages.cant_review_own_product'))
    end
  end

  private

  def recalculate_by_type(recalculate_seller, recalculate_buyer, recalculate_product)
    block = case rating_system.subject
      when RatingConstants::HOST then recalculate_seller
      when RatingConstants::GUEST then recalculate_buyer
      when RatingConstants::TRANSACTABLE then recalculate_product
      else recalculate_product
    end
    block.call
  end
end
