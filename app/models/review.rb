class Review < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  acts_as_paranoid

  PER_PAGE = 10
  LAST_30_DAYS = '30_days'
  LAST_6_MONTHS = '6_months'
  DATE_VALUES = ['today', 'yesterday', 'week_ago', 'month_ago', '3_months_ago', '6_months_ago']

  belongs_to :user
  belongs_to :reservation
  belongs_to :instance
  belongs_to :transactable_type
  
  has_many :rating_answers, -> { order(:id) }, dependent: :destroy

  validates_presence_of :rating, :object, :user
  validates :rating, inclusion: { in: RatingConstants::VALID_VALUES , message: I18n.t("activerecord.errors.models.review.rating.rating_is_required") }
  validates_length_of :comment, :maximum => 255
  validates :object, inclusion: { in: RatingConstants::FEEDBACK_TYPES }

  default_scope { order('created_at DESC') }

  scope :with_object, ->(object) { where(object: object) }
  scope :with_rating, ->(rating_value) { where(rating: rating_value) }
  scope :with_date, ->(date) { where(created_at: date) }
  scope :with_transactable_type, ->(transactable_type_id) { where(transactable_type_id: transactable_type_id) }
  scope :by_reservations, ->(id) { where(reservation_id: id).includes(:reservation, rating_answers: [:rating_question]) }
end
