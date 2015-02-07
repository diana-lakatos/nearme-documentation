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
  validates_length_of :comment, :maximum => 255
  validates :object, inclusion: { in: RatingConstants::FEEDBACK_TYPES }

  default_scope { order('created_at DESC') }

  scope :with_object, ->(object) { where(object: object) }
  scope :with_rating, ->(rating_value) { where(rating: rating_value) }
  scope :with_date, ->(date) { where(created_at: date) }
  scope :with_transactable_type, ->(transactable_type_id) { where(transactable_type_id: transactable_type_id) }
  scope :by_reservations, ->(id) { where(reviewable_id: id, reviewable_type: 'Reservation').includes(:reviewable, rating_answers: [:rating_question]) }
  scope :by_line_items, ->(id) { where(reviewable_id: id, reviewable_type: 'Spree::LineItem').includes(:reviewable, rating_answers: [:rating_question]) }

  def recalculate_reviewable_average_rating
    if self.reviewable.is_a?(Spree::LineItem) && self.object == 'seller'
      self.reviewable.product.administrator.recalculate_average_rating!
    elsif self.reviewable.is_a?(Spree::LineItem) && self.object == 'product'
      self.reviewable.product.recalculate_average_rating!
    end
  end
end
