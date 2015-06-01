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

  has_many :rating_answers, -> { order(:id) }, dependent: :destroy

  validates_presence_of :rating, :object, :user, :reviewable, :transactable_type
  validates :rating, inclusion: { in: RatingConstants::VALID_VALUES , message: :rating_is_required }
  validates :object, inclusion: { in: RatingConstants::FEEDBACK_TYPES }
  validate  :creator_does_not_review_own_objects

  default_scope { order('reviews.created_at DESC') }

  scope :with_object, ->(object) { where(object: object) }
  scope :with_rating, ->(rating_value) { where(rating: rating_value) }
  scope :with_date, ->(date) { where(created_at: date) }
  scope :with_transactable_type, ->(transactable_type_id) { where(transactable_type_id: transactable_type_id) }
  scope :by_reservations, ->(id) { where(reviewable_id: id, reviewable_type: 'Reservation').includes(:reviewable, rating_answers: [:rating_question]) }
  scope :by_line_items, ->(id) { where(reviewable_id: id, reviewable_type: 'Spree::LineItem').includes(:reviewable, rating_answers: [:rating_question]) }
  scope :for_buyer, ->{ with_object('buyer') }
  scope :for_seller, ->{ with_object('seller') }
  scope :for_seller_and_product, -> { with_object(['seller', 'product']) }
  scope :both_sides_reviewed_for, ->(object) {
    select('DISTINCT reviews.*').
    joins("INNER JOIN reviews AS rev ON rev.reviewable_type = reviews.reviewable_type
        AND rev.reviewable_id = reviews.reviewable_id").
    where("reviews.object = 'product'
      OR NOT (SELECT tt.show_reviews_if_both_completed FROM transactable_types AS tt WHERE tt.id = reviews.transactable_type_id)
      OR rev.object=?", object
    )
  }

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

  protected

  def creator_does_not_review_own_objects
    if user_id.present? && (user_id == reviewable.try(:creator_id) && user_id == reviewable.try(:owner_id))
      errors.add(:base, I18n.t('errors.messages.cant_review_own_product'))
    end
  end

  private

  def recalculate_by_type(recalculate_seller, recalculate_buyer, recalculate_product)
    block = case object
      when 'seller' then recalculate_seller
      when 'buyer' then recalculate_buyer
      when 'product' then recalculate_product
    end
    block.call
  end
end
