class Review < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  self.per_page = 10

  LAST_30_DAYS = '30_days'
  LAST_6_MONTHS = '6_months'
  DATE_VALUES = ['today', 'yesterday', 'week_ago', 'month_ago', '3_months_ago', '6_months_ago']

  belongs_to :user, -> { with_deleted }
  belongs_to :seller, -> { with_deleted }, class_name: 'User'
  belongs_to :buyer, -> { with_deleted }, class_name: 'User'
  belongs_to :reviewable, polymorphic: true
  belongs_to :instance
  belongs_to :transactable_type
  belongs_to :rating_system, -> { with_deleted }

  has_many :rating_answers, -> { order(:id) }, dependent: :destroy

  before_validation :set_foreign_keys_and_subject, on: :create
  before_validation :set_displayable, on: :create
  validates_presence_of :rating, :user, :reviewable, :transactable_type
  validates :rating, inclusion: { in: RatingConstants::VALID_VALUES , message: :rating_is_required }
  validate  :creator_does_not_review_own_objects
  validates_uniqueness_of :user_id, scope: [:reviewable_id, :reviewable_type, :subject], conditions: -> { where(deleted_at: nil) }

  default_scope { order('reviews.created_at DESC') }

  scope :with_rating, ->(rating_value) { where(rating: rating_value) }
  scope :with_date, ->(date) { where(created_at: date) }
  scope :with_transactable_type, ->(transactable_type_id) { where(transactable_type_id: transactable_type_id) }
  scope :by_reservations, ->(id) { where(reviewable_id: id, reviewable_type: 'Reservation').includes(rating_answers: [:rating_question]) }
  scope :by_line_items, ->(id) { where(reviewable_id: id, reviewable_type: ['LineItem::Transactable', 'LineItem']).includes(rating_answers: [:rating_question]) }
  scope :by_search_query, -> (query) { joins(:user).where("users.name ILIKE ?", query) }
  scope :displayable, -> { where(displayable: true).joins(:rating_system).where('rating_systems.active = ?', true) }
  scope :about_seller , -> (user) { displayable.where(seller_id: user.id, subject: RatingConstants::HOST).where.not(user_id: user.id) }
  scope :about_buyer, -> (user) { displayable.where(buyer_id: user.id, subject: [RatingConstants::GUEST]).where.not(user_id: user.id) }
  scope :left_by_seller, -> (user) { displayable.where(seller_id: user.id, user_id: user.id, subject: RatingConstants::GUEST) }
  scope :left_by_buyer, -> (user) { displayable.where(buyer_id: user.id, user_id: user.id, subject: [RatingConstants::HOST, RatingConstants::TRANSACTABLE]) }
  scope :for_reviewables, -> (ids, type) { where(subject: RatingConstants::TRANSACTABLE, reviewable_id: ids, reviewable_type: type) }
  scope :active_with_subject, -> (subject) { joins(:rating_system).merge(RatingSystem.active_with_subject(subject)) }
  scope :for_type_of_transactable_type, -> (type) { joins(:rating_system).merge(RatingSystem.for_type_of_transactable_type(type) ) }

  after_commit :expire_cache

  def recalculate_reviewable_average_rating
    if reviewable_type == "Spree::LineItem"
      recalculate_by_type(-> { self.reviewable.product.recalculate_average_rating! })
    elsif reviewable_type == "Bid"
      recalculate_by_type(-> { self.reviewable.offer.recalculate_average_rating! })
    else
      recalculate_by_type(-> { self.reviewable.transactable.recalculate_average_rating! })
    end
  end

  def expire_cache
    Rails.cache.delete_matched("reviews_view/#{reviewable_object.cache_key}/*")
    Rails.cache.delete_matched("reviews_view/#{seller.cache_key}/*")
    Rails.cache.delete_matched("reviews_view/#{buyer.cache_key}/*")
  end

  def reviewable_object
    reviewable.try(:line_item_source) || reviewable.try(:transactable) || reviewable.try(:offer)
  end

  protected

  def set_foreign_keys_and_subject
    self.buyer_id = reviewable.try(:owner_id) || reviewable.try(:user_id)
    self.seller_id = reviewable.try(:creator_id) || reviewable.try(:offer_creator_id)
    self.subject = rating_system.subject
  end

  def set_displayable
    if [RatingConstants::HOST, RatingConstants::GUEST].include?(subject)
      review = Review.find_by(reviewable_id: reviewable_id, reviewable_type: reviewable_type, subject: [RatingConstants::HOST, RatingConstants::GUEST])
      review.try(:update_column, :displayable, true)
      review.try(:recalculate_reviewable_average_rating)
      if review.nil? && transactable_type.show_reviews_if_both_completed
        self.displayable = false
      end
    end
    true
  end

  def creator_does_not_review_own_objects
    if buyer_id == seller_id
      errors.add(:base, I18n.t('errors.messages.cant_review_own_product'))
    end
  end

  def to_liquid
    @review_drop ||= ReviewDrop.new(self)
  end

  private

  def recalculate_by_type(recalculate_product)
    case rating_system.subject
    when RatingConstants::HOST
      self.seller.recalculate_seller_average_rating!
      self.buyer.recalculate_left_as_buyer_average_rating!
    when RatingConstants::GUEST
      self.buyer.recalculate_buyer_average_rating!
      self.seller.recalculate_left_as_seller_average_rating!
    when RatingConstants::TRANSACTABLE
      recalculate_product.call
      self.buyer.recalculate_left_as_buyer_average_rating!
    else
      raise NotImplementedError
    end
    true
  end
end
